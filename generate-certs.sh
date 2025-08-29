#!/bin/bash

# Generate self-signed certificate for registry.local
echo "Generating self-signed certificate for registry.local..."

# Create private key
openssl genrsa -out certs/registry.key 4096

# Create certificate signing request
openssl req -new -key certs/registry.key -out certs/registry.csr -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=registry.local"

# Create certificate with SAN (Subject Alternative Name)
cat > certs/registry.conf << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = US
ST = State
L = City
O = Organization
OU = OrgUnit
CN = registry.local

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = registry.local
DNS.2 = localhost
DNS.3 = workstation
IP.1 = 127.0.0.1
IP.2 = 192.168.0.16
IP.3 = 100.108.185.48
EOF

# Generate self-signed certificate valid for 365 days
openssl x509 -req -in certs/registry.csr -signkey certs/registry.key -out certs/registry.crt -days 365 -extensions v3_req -extfile certs/registry.conf

# Set proper permissions
chmod 600 certs/registry.key
chmod 644 certs/registry.crt

echo "Certificate generated successfully!"
echo "Certificate: certs/registry.crt"
echo "Private key: certs/registry.key"

# Display certificate info
echo -e "\nCertificate details:"
openssl x509 -in certs/registry.crt -text -noout | grep -E "(Subject:|DNS:|IP Address:|Not After)"
