
extern crate serde_json;
extern crate sysfs_gpio;

use serde::{Deserialize, Serialize};
use serde_json::Result;

use sysfs_gpio::{Direction, Pin};
use std::sync::mpsc;
use std::thread;
use std::thread::sleep;
use std::time::Duration;

// default configuration
const DEFAULT_CONFIG_FILE:&str = "/etc/ledserver.yaml";
const DEFAULT_BITTIME_MS:u64 = 2000;


// A single pattern for a single LED
#[derive(Serialize, Deserialize)]
struct Pattern {
    ledid: u8,
    pattern: Vec<u8>,
}

// What the json will be matched to
#[derive(Serialize, Deserialize)]
struct JsonSchema {
    ledpatterns: Vec<Pattern>,
    version: u8,
}



fn led_daemon(rx:mpsc::Receiver<String>) {

    let bittime_ms = DEFAULT_BITTIME_MS;


    // open all LEDs
    let redled = Pin::new(21);
    match redled.export() {
        Ok(()) => println!("Gpio {} exported!", redled.get_pin()),
        Err(err) => println!("Gpio {} could not be exported: {}", redled.get_pin(), err),
    }
    redled.set_direction(Direction::Out).unwrap();


    loop {
        match rx.try_recv() {
            Ok(received) => {
                println!("Got new message: {}", received);
                let lp: JsonSchema = serde_json::from_str(&received).unwrap(); // TODO: Fail on parse error
                println!("{:?}", lp.version);
                println!("{:?}", lp.ledpatterns[0].pattern);
            }
            Err(err) => println!("didnt get new message {}", err ),
        }

        println!("OFF");
        redled.set_value(0).unwrap();
        sleep(Duration::from_millis(bittime_ms));
        println!("ON");
        redled.set_value(1).unwrap();

        //sleep until next bit time
        sleep(Duration::from_millis(bittime_ms));
    }


    //redled.unexport();
}

fn main() {
    println!("It's starting!");

    //TODO: Argument parsing
    //TODO: config file parsing

    //TODO: socket server
    let (tx, rx) = mpsc::channel();
    let handle = thread::spawn(move || {
        led_daemon(rx);
    });

    let data = r#"
    {"ledpatterns": [{"ledid": 2,
                  "pattern": [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1]},
                 {"ledid": 3, "pattern": [0, 0, 0, 0, 1, 1, 1, 1]}],
     "version": 0}
    "#;
    tx.send(data.to_string()).unwrap();

    //TODO: Terminate gently?
    handle.join().unwrap();
}
