#!/usr/bin/env zsh

# Simple script to create a demo PKI with a root CA, an intermediate CA,
# and a leaf (server) certificate, along with various bundle files.

set -eu
set -o pipefail

# Output dir (customize if you like)
OUT="${1:-demo-pki}"
mkdir -p "$OUT"
cd "$OUT"

# --- Minimal OpenSSL config files ---
cat > root.cnf <<'EOF'
[ req ]
prompt = no
distinguished_name = dn
x509_extensions = v3_ca
[ dn ]
CN = Demo Root CA
[ v3_ca ]
basicConstraints = critical, CA:true, pathlen:1
keyUsage = critical, keyCertSign, cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
EOF

cat > inter.cnf <<'EOF'
[ req ]
prompt = no
distinguished_name = dn
[ dn ]
CN = Demo Intermediate CA
[ v3_ca ]
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, keyCertSign, cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
EOF

cat > leaf.cnf <<'EOF'
[ req ]
prompt = no
distinguished_name = dn
req_extensions = v3_req
[ dn ]
CN = simplesecure
[ v3_req ]
basicConstraints = critical, CA:false
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = demo.example.local
DNS.2 = localhost
EOF

# --- Keys & certs ---
# Root CA
openssl genrsa -out root.key 2048 >/dev/null 2>&1
openssl req -new -x509 -days 3650 -sha256 \
  -key root.key -out root.pem \
  -config root.cnf -extensions v3_ca

# Intermediate CA
openssl genrsa -out inter.key 2048 >/dev/null 2>&1
openssl req -new -sha256 -key inter.key -out inter.csr -config inter.cnf
openssl x509 -req -days 1825 -sha256 \
  -in inter.csr -CA root.pem -CAkey root.key -CAcreateserial \
  -out inter.pem -extfile inter.cnf -extensions v3_ca

# Leaf (server) cert
openssl genrsa -out leaf.key 2048 >/dev/null 2>&1
openssl req -new -sha256 -key leaf.key -out leaf.csr -config leaf.cnf
openssl x509 -req -days 825 -sha256 \
  -in leaf.csr -CA inter.pem -CAkey inter.key -CAcreateserial \
  -out leaf.pem -extfile leaf.cnf -extensions v3_req

# --- Bundles (public certs only) ---
# Ordered (leaf -> intermediate -> root)
cat leaf.pem inter.pem root.pem > chain-ordered.pem
# Unordered (for testing)
cat inter.pem leaf.pem root.pem > chain-unordered.pem
# Trust-bundle (typical truststore content; no leaf)
cat inter.pem root.pem > trust-bundle.pem

# --- Quick sanity checks ---
echo "Verifying chain:"
openssl verify -CAfile root.pem -untrusted inter.pem leaf.pem

echo
echo "Wrote files in $(pwd):"
ls -1
echo
echo "Tip: split a bundle into individual certs with:"
echo "  awk 'BEGIN{n=0} /-----BEGIN CERTIFICATE-----/{n++; fn=sprintf(\"cert-%02d.pem\", n)} {print > fn}' chain-unordered.pem"
