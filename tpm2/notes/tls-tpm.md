# Collections of URLS and notes for TLS+TPM stuff

# Official / introductory resources
TPM spec is really dry, I will not bother with it.

There is an open access book that is less dry than the official spec, but it does not tell you how to use the TPM at all.
https://www.apress.com/gp/book/9781430265832

There is a very well written question that describes someone's quest to use TPM2 from C# on Microsoft. While it is not applicable to Linux development and is rather outdated (written in 2015, last updates ~2018), it is describing a lot of things that we would like to do with TPM2 and is a nice read.
https://stackoverflow.com/questions/28862767/how-to-encrypt-bytes-using-the-tpm-trusted-platform-module

# https://github.com/tpm2-software resources

Note that part of this official group is the Python bindings fot TSS: https://tpm2-software.github.io/tpm2-pytss/

# Infineon resources

# Nginx resources
This issue documents someone's step-by-step successful attempts to use TPM as the ssl engine in nginx: https://github.com/tpm2-software/tpm2-tss-engine/issues/91

Nginx: configuring encrypted private keys (No TPM):
https://www.nginx.com/blog/secure-distribution-ssl-private-keys-nginx/

# Golang resources
Go has two packages for interacting with TPM, one from Google and one from Canonical. We prefer the Google one since it is likely to have production use in GCP, plus the canonical one is LGPLV3(with link exception).
https://pkg.go.dev/github.com/google/go-tpm/tpm2?tab=doc
https://pkg.go.dev/github.com/canonical/go-tpm2?tab=doc

Google also have a library containing some higher level API:
https://github.com/google/go-tpm-tools

There is also a bloke which probably works for Google and wrote a shit ton of examples on how to use these libraries, with comparison on how to do it with CLI tools (which could be a good example on how to use the CLI tools)
https://github.com/salrashid123/tpm2

# Rust resources
Looks like the only thing that talks TPM in Rust is this one crate. Support does not seem to be as wide as golang.
https://crates.io/crates/tss-esapi


#Outdated but still potentially useful

A bloke added TPM backed SSL to his codebase about 8 years ago.
Notable that it includes actual benchmarking data (0.7s / handshake).
https://blog.habets.se/2012/02/TPM-backed-SSL.html
https://blog.habets.se/2012/02/Benchmarking-TPM-backend-SSL.html

ONAP TPM / HSM analysis. Contains analysis of the state of open source implementations. A bit unintuitive, but maybe useful if we go down further. Circa 2018.
https://wiki.onap.org/pages/viewpage.action?pageId=20875223

Two posts about using hardware modules to back mbedTLS.
The response circa 2018 is that you need to add your own implementations. This sounds rather painful so I am not sure this is a good approach.
https://tls.mbed.org/discussions/crypto-and-ssl/possible-to-specify-tpm-for-mbedtls
https://tls.mbed.org/discussions/generic/mbedtls-support-for-external-keys-and-certs-on-chip

https://www.cs.unh.edu/~it666/reading_list/Hardware/tpm_fundamentals.pdf (2008, outdated)
