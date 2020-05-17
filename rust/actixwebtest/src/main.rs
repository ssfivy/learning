use actix_web::{web, App, HttpRequest, HttpServer, Responder};


async fn index(_req: HttpRequest) -> impl Responder {
    "Hello from the index page!"
}

async fn hello(path: web::Path<String>) -> impl Responder {
    format!("Hello {}!", &path)
}



#[actix_rt::main]
async fn main() -> std::io::Result<()> {
    println!("Starting!");
    HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(index))
            .route("/{name}", web::get().to(hello))
    })
    .bind("127.0.0.1:8000")?
    .run()
    .await
}
