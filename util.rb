require "json"

# try first to load config from json
if File.exist?("#{ENV["HOME"]}/.ca-config.json")
  values = JSON.parse(File.read("#{ENV["HOME"]}/.ca-config.json"))
  @cert_dir = values["certDir"]
  @country = values["country"]
  @location = values["location"]
  @organization = values["organization"]
  @expiration = values["expiration"]
end

# then from environment, falling back to defaults
@cert_dir ||= ENV["CERT_DIR"] || "#{ENV["HOME"]}/local/etc/certs"
@country ||= ENV["CERT_COUNTRY"] || "US"
@location ||= ENV["CERT_LOCATION"] || "California"
@organization ||= ENV["CERT_ORGANIZATION"] || "Snake Oil Ltd."
@expiration ||= ENV["CERT_EXPIRATION"] || "87600h"

@cfssl = `which cfssl`.strip
if @cfssl.length =~ /^\s*$/
  STDERR.puts "Could not find cfssl in path"
  exit 1
end

@cfssl_initca=[
  @cfssl,
  "gencert",
  "-initca",
  "-",
]

@cfssl_sign=[
  @cfssl,
  "sign",
  "-config=../ca-config.json",  # relative paths, because we will chdir to wherever the
  "-ca=../ca-cert.pem",         # certificate is being placed.  That way, intermediate
  "-ca-key=../ca-key.pem",      # ca configs will be used instead of the root ca config
  "-profile=intermediate",
  "-",
]

@cfssl_client=[
  @cfssl,
  "gencert",
  "-ca=../../ca-cert.pem",
  "-ca-key=../../ca-key.pem",
  "-config=../../ca-config.json",
  "-profile=client",
  "-",
]

@cfssl_server=[
  @cfssl,
  "gencert",
  "-ca=../ca-cert.pem",
  "-ca-key=../ca-key.pem",
  "-config=../ca-config.json",
  "-profile=server",
  "-",
]

if !File.exist?(@cert_dir) 
    STDERR.puts "Certificate directory #{@cert_dir} does not exist"
    exit 2
elsif !File.directory?(@cert_dir)
    STDERR.puts "Certificate directory #{@cert_dir} is not a directory"
    exit 3
end

def check_no_ca
  ["ca-cert.pem", "ca.csr", "ca-key.pem", "ca-config.json"].each do |filename|
    if File.exist?("#{@cert_dir}/#{filename}")
      STDERR.puts "It appears that a CA is alread configured in #{@cert_dir}"
      exit 4
    end
  end
end
