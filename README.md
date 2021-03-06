

# Create Root CA
1. Create ca-csr.json
```json
{
  "CN": "#{common_name}",
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "C": "#{country}",
      "L": "#{location}",
      "O": "#{organization}",
      "OU": "#{organizational_unit}"
    }
  ],
  "ca": {
    "expiry": "#{expiration}"
  }
}
```
2. Create ca-config.json
```json
{
  "signing": {
    "default": {
      "expiry": "#{expiration}",
      "usages": ["digital signature","cert sign","crl sign","signing"],
      "ca_constraint": {
        "is_ca": true,
        "max_path_len":0,
        "max_path_len_zero": true
      }
    }
  }
}
```
3. cfssl gencert -initca csr_ROOT_CA.json | cfssljson -bare root_ca

# Create Intermediate CA
1. mkdir #{ca_dir}
2. chdir #{ca_dir}
3. Create ca-csr.json
```json
{
  "CN": "#{common_name}",
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "C": "#{country}",
      "L": "#{location}",
      "O": "#{organization}",
      "OU": "#{organizational_unit}"
    }
  ],
  "ca": {
    "expiry": "#{expiration}"
  }
}
```
4. cfssl gencert -initca ca-csr.json | cfssljson -bare intermediate_ca
5. cfssl sign -ca ../ca.pem -ca-key=../ca-key.pem -config=../ca-config.json cert.csr | cfssljson -bare intermediate_ca

# Create Server Key/Certificate
1. mkdir #{host}
2. chdir #{host}
3. Creat csr.json
```json
{
  "CN": "#{fqdn}",
  "hosts": [ "#{host}", "#{fqdn}", "#{alt_subj_name}" ],
  "key": {
      "algo": "ecdsa",
      "size": 256
  },
  "names": [
      {
          "C":  "#{country}",
          "O":  "#{organization}"
      }
  ]
}
```
4. cfssl gencert -config ../ca-config.json -ca ../ca.pem -ca-key ../ca-key.pem csr.json | cfssljson -bare

# Create Client Key/Certificate
1. mkdir accounts/#{username}
2. chdir accounts/#{username}
3. Creat csr.json
```json
{
  "CN": "#{username}",
  "hosts": [""],
  "key": {
      "algo": "ecdsa",
      "size": 256
  },
  "names": [
      {
          "C":  "#{country}",
          "O":  "#{organization}"
      }
  ]
}
```
4. cfssl gencert -config ../../ca-config.json -ca ../../ca.pem -ca-key ../../ca-key.pem csr.json | cfssljson -bare 
