#!perl

use strict;
use warnings;
use AnyEvent;
use Unruly;
use utf8;
use Net::Twitter::Lite::WithAPIv1_1;
use Data::Dumper;
use FindBin qw($Bin);

my $config = do "$Bin/../config.pl";

my $ur = Unruly->new(url => 'http://yancha.hachiojipm.org', tags => {PUBLIC => 1});
$ur->twitter_login($config->{twitter_id}, $config->{twitter_pass});

my $cv = AnyEvent->condvar;

our $nt = Net::Twitter::Lite::WithAPIv1_1->new(
    consumer_key    => $config->{consumer_key},
    consumer_secret => $config->{consumer_secret},
    access_token        => $config->{access_token},
    access_token_secret => $config->{access_token_secret},
    ssl                 => 1,
);

unless ( $nt->authorized ) {
    die "fail authorize"; 
}
warn "Twitter Auth success.";

$ur->run(sub {
    my ( $client, $socket ) = @_;
    $socket->on('user message', sub {
        my $post = $_[1];
        my @tags = @{$post->{tags}};
        my $nick = $post->{nickname};
        my $text = $post->{text};
        if($post->{is_message_log}){ # PlusPlus and other.
            return;
        }

        if($text =~ /^(@[a-z_0-9]{1,15})/){
            my $name = $1;
            $text =~ s/@/(at)/g;
            $text = substr($text,0,100);
            warn sprintf('%s calling to %s', $nick, $name);
            my $result = eval { 
                $nt->new_direct_message(
                    {
                        screen_name => $name,
                        text        => "${nick}が呼んでます「${text}」"
                    }
                )
            };
            $name =~ s/@//;
            # warn Dumper($result);
            if(!defined($result)){
                warn "can't send to ${name}";
                $ur->post("${name}の住所がわかりませんでした", ('PUBLIC'));
                return;
            }

            $result = eval{ $nt->update("${nick}が${name}に赤紙を送りました") } ;
            # warn Dumper($result) if $result;
            $ur->post("${name}に赤紙を送りました", ('PUBLIC'));
        }

    });
});

$cv->wait;
