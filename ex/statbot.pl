#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Data::Dumper qw/Dumper/;

=head1 NAME

statbot.pl

=head1 DESCRIPTION

A simple example bot for Rocket::Chat::Streaming to demonstrate collecting
statistics of conversations, on a per user and per room basis.

=cut

use Rocket::Chat::Streaming;

my $api  = $ENV{RCS_BOT_API}  || die "env var RCS_BOT_API not set\n";
my $user = $ENV{RCS_BOT_USER} || die "env var RCS_BOT_USER not set\n";
my $pass = $ENV{RCS_BOT_PASS} || die "env var RCS_BOT_PASS not set\n";

# create object
my $rc = Rocket::Chat::Streaming->new(url => $api);

# register callbacks
$rc->on(connect => sub { $rc->login($user, $pass); });
$rc->on(error => sub { my ($err) = @_;  warn "Error occurred - exiting:\n".Dumper($err); exit; });
$rc->on(logged_in => sub { say "Login successful!"; $rc->get_rooms() } );

# for debugging purposes
# $rc->on(all_msg => sub { warn Dumper(shift); });

# initiate connection
$rc->connect();

# print some debugging until we log in
Mojo::IOLoop->recurring(1 => sub {
  return if ($rc->is_logged_in);
  say "Session:   " . ($rc->session || 'undef');
  say "Token:     " . ($rc->token   || 'undef');
  say "Connected: " . $rc->is_connected;
  say "Logged in: " . $rc->is_logged_in;
});

# run event loop, forever
$rc->start;
