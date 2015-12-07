package Corp::Test;

use strict;
use warnings;
use Smart::Comments;

use Test::Base -Base;
use JSON;
use LWP::UserAgent;
use HTTP::Request::Common;
use Digest::MD5 qw/md5_hex md5/;
use URI::Escape;
use MIME::Base64;

our @EXPORT = qw/run_blocks/;

my $ua=LWP::UserAgent->new();
$ua->timeout(10);
$ua->max_redirect(0);

#---------------------------------------------------------
# TODO append your utility functions here
#---------------------------------------------------------

sub expand_var ($) {
  my $data = shift || '';

  $data =~ s/\$([A-Z0-9_]+)/
    if (!defined $ENV{$1}) {
      die "No environment variable $1 defined.\n";
    }
  $ENV{$1}/eg;

  $data;
}


sub make_http_request (@) {
  my %hash = @_;

  my $host = $hash{host} || 'localhost';
  my $port = $hash{port} || '8080';
  my $uri = $hash{uri};
  my $header = $hash{header} || '';
  my $form = $hash{form} || '';
  my $data = $hash{data} || '';

  my $url = $uri;
  if ($uri =~ /^\//) {
    $url = "http://$host:$port$uri";
  }

  ### $url
  if ($form && $data) {
    die "form conflict with data\n";
  }

  my $method = $form || $data ? 'POST' : 'GET';

  $header =~ s/(?:^\s+|\s+$)//gs;
  my @headers = split /\n/, $header;
  @headers = map {
    my ($k, $v) = split /\s*:\s*/;
    {$k => $v}
  } @headers;

  if ($method eq 'GET') {
    return GET $url, @headers;
  }

  # POST http body
  if ($data) {
    my $req = POST $url, @headers;
    $req->content($data);
    return $req;
  }

  # POST form
  my @lines = split /\n/, $form;
  my @content = map {
    my ($k, $v) = split /\s*=/;
    if ($v =~/^@(.*$)/) {
      $v = [$1];
    }
    {$k => $v}
  } @lines;

  return POST $url, Content_Type => 'form-data', @headers, Content => \@content;
}


sub run_block($) {
  my $block = shift;

  my $name = $block->name;

  # prepare
  my $req = make_http_request (
    host => $ENV{TEST_HOST},
    port => $ENV{TEST_PORT},
    uri => &expand_var($block->uri),
    header => $block->header || '',
    form => $block->form || '',
    data => $block->data || ''
  );

  # execute
  my $resp = $ua->request($req);

  my $resp_code = $resp->code;
  my $resp_content = undef;
  my $resp_header_location = undef;

  if ($resp->is_success) {
    $resp_content = $resp->content;
  } elsif ($resp->is_redirect) {
    $resp_header_location = $resp->header("Location");
  } else {
    my $err = $resp->content;
    ### $err
  }

  my $response_code = $block->response_code;
  my $response = &expand_var($block->response);
  my $response_header_location = &expand_var($block->response_header_location);

  is ($resp_code, $response_code, "$name response code");

  if ($response =~ /^\{.*\}$/s) {
    my $response_ref = decode_json $response;
    my $resp_content_ref = decode_json $resp_content;
    is_deep($resp_content_ref, $response_ref, "$name response json");
  } elsif ($response) {
    is ($resp_content, $response, "$name response text");
  } elsif ($response_header_location) {
    is ($resp_header_location, $response_header_location, "$name redirect");
  } else {
    is (1, 1);
  }
}

sub run_blocks () {
  for my $block (blocks) {
    run_block($block);
  }
}
