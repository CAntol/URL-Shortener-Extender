#!/user/bin/ruby

require 'net/https'

def shorten(api_key, url, root, path, headers)
	data = "{\"key\": \"#{api_key}\", \"longUrl\": \"#{url}\"}"

	uri = URI.parse(root + path)

	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true

	resp, data = http.post(path, data, headers)

	puts data.split("\"")[7] # to be replaced by JSON or regex or multi splitting
end

def lengthen(api_key, url, root, path, headers)
	data = "?key=#{api_key}&shortUrl=#{url}"
	uri = URI.parse(root + path + data)
	
	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	
	response, data =  http.start do |http|
		http.get(uri.request_uri, headers)
	end

	puts data.split("\"")[11] # to be replaced by JSON or regex or multi splitting
end

def usage
	puts "Usage: ruby url.rb http(s)://example.com"
end

begin
url = ARGV[0]

if url.split("/")[2].downcase == "goo.gl"
	method = "lengthen"
else
	method = "shorten"
end

# read api key from file
f = File.open("creds", "r")
api_key = f.readline
f.close

root = "https://www.googleapis.com"
path = "/urlshortener/v1/url"

headers = {"Content-Type" => "application/json"}

if method == "shorten"
	shorten(api_key, url, root, path, headers)
elsif method == "lengthen"
	lengthen(api_key, url, root, path, headers)
else
	usage
end

rescue
	usage
end