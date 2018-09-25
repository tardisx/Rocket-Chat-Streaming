use Test::More;
use Test::Exception;

use_ok('Rocket::Chat::RealTime');

my $rc = Rocket::Chat::RealTime->new;
ok($rc, 'created object');

throws_ok { $rc->connect } qr/no url supplied/i, 'cannot connect with no URL';

done_testing();
