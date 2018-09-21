use Test::More;
use Test::Exception;

use_ok('Rocket::Chat::Streaming');

my $rc = Rocket::Chat::Streaming->new;
ok($rc, 'created object');

throws_ok { $rc->connect } qr/no url supplied/i, 'cannot connect with no URL';

done_testing();
