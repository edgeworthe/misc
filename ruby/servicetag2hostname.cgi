#!/usr/bin/ruby 
# given service tag, return hostname based on
# data stored in flatfile
# queried via webserver as e.g. servicetag2hostname.cgi?ABCDEFG1

require 'CGI'

cgi = CGI.new

datafilename = "/var/tmp/servicetags2hostnames.txt"

query_servicetag = ARGV.first
response_hostname = ""
response_status = "OK"

if query_servicetag
    # TODO: consider better handling of e.g. file not
    # found errors
    for line in File.open(datafilename).readlines()
        servicetag, hostname = line.chomp().split()
        if servicetag == query_servicetag
            response_hostname = hostname
            break
        end
    end
    if response_hostname == ""
        response_status = "NOT_FOUND"
    end
else
    response_status = "BAD_REQUEST"
end

print cgi.header("status" => response_status), response_hostname
if response_status != "OK"
    print response_status
end
