package main

import (
	"crypto/tls"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"time"
)

func h2h(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hi there, I hate %s!", r.URL.Path[1:])
}

func cmd_finish(cmd *exec.Cmd) {
	// And when you need to wait for the command to finish:
	pid := cmd.Process.Pid
	err := cmd.Wait()
	if err != nil {
		log.Printf("cmd.Wait() error: %v", err)
	} else {
		log.Printf("Process %d just terminates ", pid)
	}
}

func h1h(w http.ResponseWriter, r *http.Request) {
	log.Printf("GOt net/http %s %s %s", r.Proto, r.Method, r.URL)
	log.Printf("Headers %s", r.Header)
	//TODO: something with r.Body?
	switch r.Method {
	case http.MethodGet:
		fmt.Fprintf(w, "Hi there, I love %s!", r.URL.Path[1:])
	case http.MethodPost:
		fmt.Fprintf(w, "Posted: %s", r.Body)
		cmd := exec.Command("bash", "script.sh")
		cmd.Stdout = os.Stdout
		err := cmd.Start()
		if err != nil {
			log.Fatal(err)
		}
		log.Printf("Just started subprocess %d", cmd.Process.Pid)
		go cmd_finish(cmd)
	case http.MethodPut:
		fmt.Fprintf(w, "Running goroutine benchmark code (lol wut?)")
		n := 2
		//hey we can take allll cpu time on all cores easily unlike Python!
		// careful calling this, this will very easily peg all your cpu
		for i := 0; i < n; i++ {
			go func() {
				//spin and take all cpu time
				for {
					continue
				}
			}()
		}
	case http.MethodDelete:
		fmt.Fprintf(w, "Deleting stuff")
	default:
		fmt.Fprintf(w, "No clue what you sent me mate")
	}
}

/*
Useful URL:
https://blog.cloudflare.com/exposing-go-on-the-internet/
https://blog.cloudflare.com/the-complete-guide-to-golang-net-http-timeouts/
https://www.alexedwards.net/blog/a-recap-of-request-handling
*/

func main() {

	// SYSTEM STUFFS
	log.Println("G'day, Mate!")
	go func() {
		ch := make(chan os.Signal, 1)
		signal.Notify(ch, os.Interrupt)
		<-ch
		log.Printf("signal caught. shutting down...")
		os.Exit(0)
	}()

	// ROUTING STUFFS
	mux := http.NewServeMux()
	mux.HandleFunc("/h1/", h1h)
	mux.HandleFunc("/h2/", h2h)

	// CERTIFICATES STUFF

	//generate_cert()
	certname, keyname := generate_cert()

	// CRYPTO STUFFS
	tlsConfig := &tls.Config{
		// Causes servers to use Go's default ciphersuite preferences,
		// which are tuned to avoid attacks. Does nothing on clients.
		PreferServerCipherSuites: true,
		// Only use curves which have assembly implementations
		CurvePreferences: []tls.CurveID{
			tls.CurveP256,
			tls.X25519, // Go 1.8 only
		},
		MinVersion: tls.VersionTLS12,
		CipherSuites: []uint16{
			tls.TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
			tls.TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
			tls.TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305, // Go 1.8 only
			tls.TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,   // Go 1.8 only
			tls.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
			tls.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,

			// Best disabled, as they don't provide Forward Secrecy,
			// but might be necessary for some clients
			// tls.TLS_RSA_WITH_AES_256_GCM_SHA384,
			// tls.TLS_RSA_WITH_AES_128_GCM_SHA256,
		},
	}

	// WEB SERVER STUFFS

	// Set up HTTP to HTTPS redirect
	// Somehow doesnt work for now
	srv := &http.Server{
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 5 * time.Second,
		Handler: http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
			w.Header().Set("Connection", "close")
			url := "https://" + req.Host + req.URL.String()
			http.Redirect(w, req, url, http.StatusMovedPermanently)
		}),
		Addr: ":8080",
	}
	go func() { log.Fatal(srv.ListenAndServe()) }()

	// Set up our HTTPS server
	srvs := &http.Server{
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		Handler:      mux,
		IdleTimeout:  120 * time.Second,
		TLSConfig:    tlsConfig,
		Addr:         ":8443",
	}

	log.Println(srvs.ListenAndServeTLS(certname, keyname))

	// should not reach here
	os.Exit(0)
}
