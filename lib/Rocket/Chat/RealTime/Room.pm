use strict;
use warnings;
package Rocket::Chat::RealTime::Room;

use Mojo::Base       qw/-base/;

use Carp             qw/confess/;

has 'id';
has 'name';
has 'ro';
has 'type';

1;

__DATA__
# {
#           'msg' => 'result',
#           'id' => '2',
#           'result' => [
#                         {
#                           'sysMes' => bless( do{\(my $o = 1)}, 'JSON::PP::Boolean' ),
#                           'name' => 'bottest',
#                           'ro' => bless( do{\(my $o = 0)}, 'JSON::PP::Boolean' ),
#                           't' => 'c',
#                           'customFields' => {},
#                           '_updatedAt' => {
#                                             '$date' => '1537785859910'
#                                           },
#                           'u' => {
#                                    '_id' => 'zHFPDjAk8NpvB3XkX',
#                                    'username' => 'username'
#                                  },
#                           'fname' => 'bottest',
#                           '_id' => 'JNp7zzWaG68SqPtHd',
#                           'default' => $VAR1->{'result'}[0]{'ro'}
#                         }
#                       ]
#         };
