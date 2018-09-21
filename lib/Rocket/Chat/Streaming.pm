use strict;
use warnings;
package Rocket::Chat::Streaming;

use Mojo::Base;

# ABSTRACT: An interface to the RocketChat streaming API

=head1 SYNOPSIS

  my $api_url = 'wss://chat.domain.com/websocket';

  # create object
  my $rc = Rocket::Chat::Streaming->new(url => $api_url);

  # register callbacks
  $rc->on(connect => sub { $rc->login($username, $password); });

  # initiate connection
  $rc->connect();

  # run event loop, forever
  $rc->start;

=cut

has 'url';

1;
