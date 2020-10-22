// Guide: https://cybernetist.com/2020/05/18/getting-started-with-go-ldap/
// Library: https://github.com/go-ldap/ldap

package main

import (
	"crypto/tls"
	"fmt"
	"github.com/go-ldap/ldap/v3"
	"log"
)

const LDAP_HOST string = "192.168.218.217"
const LDAP_PORT int = 389

func ldap_dostuff(ldap_host string, ldap_port int, starttls bool) error {
	ldapURL := fmt.Sprintf("ldap://%s:%d", ldap_host, ldap_port)
	l, err := ldap.DialURL(ldapURL)
	if err != nil {
		log.Fatal(err)
	}
	log.Println("Connect success!")
	defer l.Close()

	if starttls {
		// Now reconnect with TLS
		err = l.StartTLS(&tls.Config{InsecureSkipVerify: true})
		if err != nil {
			log.Fatal(err)
		}
	}

	err = l.Bind("cn=Administrator,cn=Users,dc=fakedomain,dc=com", "adminpassword")
	if err != nil {
		log.Fatal(err)
	}

	user := "testuser1"
	baseDN := "cn=Users,DC=fakedomain,DC=com"
	filter := fmt.Sprintf("(CN=%s)", ldap.EscapeFilter(user))

	// Filters must start and finish with ()!
	searchReq := ldap.NewSearchRequest(baseDN, ldap.ScopeWholeSubtree,
		0, 0, 0, false, filter,
		[]string{"memberOf", "sAMAccountName"}, []ldap.Control{})

	result, err := l.Search(searchReq)
	if err != nil {
		return fmt.Errorf("failed to query LDAP: %w", err)
	}

	log.Println("Got", len(result.Entries), "search results")
	for _, entry := range result.Entries {
		for _, memberof := range entry.GetAttributeValues("memberOf") {
			fmt.Printf("%s: %v\n", entry.DN, memberof)
		}
		fmt.Printf("%s: %v\n", entry.DN, entry.GetAttributeValues("sAMAccountName"))
	}
	fmt.Printf("%v\n", result.Entries[0].GetAttributeValues("memberOf"))

	return nil
}

func main() {
	log.Println("Starting up!")
	ldap_dostuff(LDAP_HOST, LDAP_PORT, false)
}
