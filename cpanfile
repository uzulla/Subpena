requires 'perl', '5.008001';
requires 'JSON';
requires 'PocketIO::Client::IO';
requires 'URI';
requires 'WWW::Mechanize';
requires 'Net::Twitter::Lite::API::V1_1';
requires 'Net::OAuth';
requires 'FindBin::Bin';
on 'test' => sub {
    requires 'Test::More', '0.98';
};

