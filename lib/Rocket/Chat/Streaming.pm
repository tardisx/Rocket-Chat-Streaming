use strict;
use warnings;
package Rocket::Chat::Streaming;

use Mojo::Base       qw/-base/;
use Mojo::UserAgent;
use Carp             qw/confess/;

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
has '_ua';

=method connect

Connect to the server.

=cut

sub connect {
  my $self = shift;

  confess "No url supplied to object" unless $self->url;

  $self->_ua(Mojo::UserAgent->new);
  $self->_ua->inactivity_timeout(60);

  $self->_ua->websocket($self->url => sub {
    my ($ua, $tx) = @_;
    say 'WebSocket handshake failed!' and return unless $tx->is_websocket;
    $tx->on(finish => sub {
      my ($tx, $code, $reason) = @_;
      say "WebSocket closed with status $code.";
    });
  });

}

1;
