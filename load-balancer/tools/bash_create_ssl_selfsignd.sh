#!/bin/bash

#######################################
#
# PURPOSE:
#   Generate a complete self-signed certificate chain
#
# ChangeLog:
#   2025-02-02  v0.2.0    Initial creation
#
# Notes:
#   n/a
#
#######################################

# Default values
key_size=2048
domain_name="internal.com"
days_valid=365
output_dir="."

# Convert domain name for filenames (internal.com to internal_com)
filename_domain="${domain_name//./_}"

# Function to display help message
display_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -k <key_size>               Key size for the certificates (default: 2048)"
    echo "  -d <domain_name>            Domain name for the leaf certificate, used in SAN (default: internal.com)"
    echo "  -v <days_valid>             Validity days for the certificates (default: 365)"
    echo "  -o <output_directory>       Output directory for the certificate and key files (default: current directory)"
    echo "  -h, --help                  Display this help message and exit"
    echo "Generates a complete certificate chain with SANs: Root CA -> Intermediate CA -> Leaf Certificate."
    exit 1
}

# Check for --help before processing any other options
for arg in "$@"; do
    if [[ "$arg" == "--help" ]]; then
        display_help
    fi
done

# Parse input flags
while getopts "hk:d:v:o:" opt; do
  case $opt in
    h) display_help
    ;;
    k) key_size="$OPTARG"
    ;;
    d) domain_name="$OPTARG"
    filename_domain="${domain_name//./_}" # Update filename_domain based on input
    ;;
    v) days_valid="$OPTARG"
    ;;
    o) output_dir="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1
    ;;
  esac
done

# Ensure the output directory exists
mkdir -p "$output_dir"

# Verify OpenSSL is installed
if ! command -v openssl &> /dev/null; then
    echo "OpenSSL could not be found. Please install OpenSSL."
    exit 1
fi

# Define config for SAN
san_config="[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = *.$domain_name
DNS.2 = $domain_name"

# Root CA
openssl req -x509 -new -nodes -keyout "$output_dir/${filename_domain}_rootCA.key" -newkey rsa:"$key_size" -days "$days_valid" -out "$output_dir/${filename_domain}_rootCA.pem" -subj "/C=US/ST=State/L=City/O=Organization/CN=$domain_name Root CA"

# Intermediate CA
openssl req -new -nodes -keyout "$output_dir/${filename_domain}_intermediateCA.key" -newkey rsa:"$key_size" -days "$days_valid" -out "$output_dir/${filename_domain}_intermediateCA.csr" -subj "/C=US/ST=State/L=City/O=Organization/CN=Intermediate $domain_name CA"
openssl x509 -req -in "$output_dir/${filename_domain}_intermediateCA.csr" -CA "$output_dir/${filename_domain}_rootCA.pem" -CAkey "$output_dir/${filename_domain}_rootCA.key" -CAcreateserial -out "$output_dir/${filename_domain}_intermediateCA.pem" -days "$days_valid"

# Leaf Certificate with SANs
echo "$san_config" > "$output_dir/${filename_domain}_san.cnf"
openssl req -new -nodes -keyout "$output_dir/${filename_domain}.key" -newkey rsa:"$key_size" -days "$days_valid" -out "$output_dir/${filename_domain}.csr" -subj "/C=US/ST=State/L=City/O=Organization/CN=*.$domain_name" -config "$output_dir/${filename_domain}_san.cnf"
openssl x509 -req -in "$output_dir/${filename_domain}.csr" -CA "$output_dir/${filename_domain}_intermediateCA.pem" -CAkey "$output_dir/${filename_domain}_intermediateCA.key" -CAcreateserial -out "$output_dir/${filename_domain}.crt" -days "$days_valid" -extensions v3_req -extfile "$output_dir/${filename_domain}_san.cnf"

# Create the full chain (Leaf + Intermediate + Root)
cat "$output_dir/${filename_domain}.crt" "$output_dir/${filename_domain}_intermediateCA.pem" "$output_dir/${filename_domain}_rootCA.pem" > "$output_dir/${filename_domain}_fullchain.pem"

# Create a combined file of Intermediate and Root CA certificates
cat "$output_dir/${filename_domain}_intermediateCA.pem" "$output_dir/${filename_domain}_rootCA.pem" > "$output_dir/${filename_domain}_ca_chain.pem"

echo "Certificate chain with SANs generated successfully."
echo "Files saved in: $output_dir"