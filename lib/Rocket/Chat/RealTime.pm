use strict;
use warnings;
package Rocket::Chat::RealTime;

use Mojo::Base       qw/-base/;
use Mojo::IOLoop;
use Mojo::UserAgent;
use Digest;
use Carp             qw/confess/;

# ABSTRACT: An interface to the RocketChat real-time API


=head1 SYNOPSIS

  my $api_url = 'wss://chat.domain.com/websocket';

  # create object
  my $rc = Rocket::Chat::RealTime->new(url => $api_url);

  # register callbacks
  $rc->on(connect => sub { $rc->login($username, $password); });

  # initiate connection
  $rc->connect();

  # run event loop, forever
  $rc->start;

=cut

has 'url';
has 'tx';

has '_ua';
has '_events' => sub { {} };
has '_response_handler' => sub { {} };

has 'is_connected' => 0;
has 'is_logged_in' => 0;
has 'session';
has 'token';

my $method_id = 0;

=method connect

Connect to the server. Note that this is a non-blocking call and does not
return any confirmation with respect to the authentication attempt. You
need to subscribe to the TODO callback to learn of that.

=cut

sub connect {
  my $self = shift;

  confess "No url supplied to object" unless $self->url;

  $self->_ua(Mojo::UserAgent->new);
  $self->_ua->inactivity_timeout(60);

  $self->_ua->websocket($self->url => sub {
    my ($ua, $tx) = @_;
    say 'WebSocket handshake failed!' and return unless $tx->is_websocket;

    $self->tx($tx);

    $tx->on(finish => sub {
      my ($tx, $code, $reason) = @_;
      say "WebSocket closed with status $code.";
      $self->is_connected(0);
      $self->is_logged_in(0);
      $self->session(undef);
      $self->tx(undef);
    });

    $tx->send({json => { msg => "connect", version => "1", support => ["1"] }});

    $tx->on(json => sub {
      my ($tx, $json) = @_;

      # pass the msg to the generic "all" callbacks
      if ($json->{msg}) {
        foreach (@{ $self->_events->{all_msg} || [] }) {
          $_->($json);
        }
      }

      # look for the message indicating we connected
      if ($json->{msg} && $json->{msg} eq 'connected') {
        $self->session($json->{session});
        $self->is_connected(1);

        # call our 'connect' call backs
        foreach (@{ $self->_events->{connect} || [] }) {
          $_->();
        }
      }

      # look for responses we have a registered handler for
      if ($json->{msg}             &&
          $json->{msg} eq 'result' &&
          $json->{id}) {
        my $id = $json->{id};
        if ($self->_response_handler->{$id}) {
          # pass the response to the handler
          $self->_response_handler->{$json->{id}}->($json->{result});
          # delete the handler
          delete $self->_response_handler->{$json->{id}};
        }
        else {
          warn "No handler registered for response $id";
        }
      }

      # look for an error response
      if ($json->{msg} &&
          $json->{msg} eq 'result' &&
          $json->{error}) {
        # call our 'error' call backs
        foreach (@{ $self->_events->{error} || [] }) {
          $_->($json->{error});
        }
      }

      if ($json->{msg} && $json->{msg} eq 'ping') {
        $tx->send({json => { msg => 'pong'} });
      }

    });

  });
}

=method login

Login to the server with the given username and password.

Currently only supports SHA-256, cleartext.

Requires two arguments, the cleartext username and password.

=cut

sub login {
  my $self = shift;
  my $user = shift;
  my $pass = shift;

  my $pw_digest = Digest->new('SHA-256')->add($pass)->hexdigest;
  $method_id++;

  # register the response handler
  $self->_response_handler->{$method_id} =
   sub {
    my $result = shift;
    $self->token($result->{token});
    $self->is_logged_in(1);

    # call our 'logged in' call backs
    foreach (@{ $self->_events->{logged_in} || [] }) {
      $_->();
    }
  };

  # send the request
  $self->tx->send({json =>
    {
      msg    => 'method',
      method => 'login',
      id     => "" . $method_id,
      params => [
        {
          user     => { username => $user },
          password => { digest => $pw_digest, algorithm => 'sha-256' } }
      ]
    }
  });

  return;
}

=method get_rooms


=cut

sub get_rooms {
  my $self = shift;

  $method_id++;

  $self->tx->send({json =>
    {
      msg    => 'method',
      method => 'rooms/get',
      id     => "" . $method_id,
    }
  });

  # register a handler for the response
  $self->_response_handler->{$method_id} =
    sub {
      # TODO create room objects and populate
    };

  return;
}

sub on {
  my $self = shift;
  my ($event_name, $cb) = @_;

  push @{ $self->_events->{$event_name} }, $cb;
}

=method start

Run the event loop, blocking forever.

=cut

sub start {
  if (Mojo::IOLoop->is_running) {
    confess "Mojo::IOLoop is already running - you should not call start";
  }
  Mojo::IOLoop->start;
}

1;
