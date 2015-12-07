use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Corp::Test;

#$ENV{TEST_HOST} ||= 'localhost';
#$ENV{TEST_PORT} ||= 8080;

plan tests => 2 * blocks;

filters qw/chomp/;

run_blocks;

__END__

=== TEST GET
--- uri
/check.jsp
--- response_code
200


=== TEST GET with param
--- uri
/test/get.json?name=alice
--- response_code
200
--- response
get, alice


=== TEST POST with param
--- uri
/test/post.json
--- data
name=alice
--- response_code
200
--- response
post, alice


=== TEST POST with body
--- uri
/test/requestbody.json
--- header
Content-Type : application/json;charset=UTF-8
--- data
{"name":"alice","age":12}
--- response_code
200
--- response
{"name":"alice","age":12}


=== TEST Redirect
--- uri
/test/redirect.json
--- response_code
302
--- response_header_location
http://www.example.com


=== TEST POST file
--- uri
/test/file.json
--- form
file=@data/iapp_70KB_1500_1200.jpg
--- response_code
200


=== TEST Test won't run
--- uri
/test/xxx.json
--- responsee_code
200
--- SKIP
