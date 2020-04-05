use strict;

use Test;

BEGIN { plan tests => 8 }

use IO::Handle::Util;
use MetaBookMarks::Git;

print "#Test GitHelper\n";


ok(parseStatusLine('## No commits yet on master'));
statusLine('## master', 'branch' => "master");
statusLine('## master...origin/master');
statusLine('## master...origin/master [ahead 1]', branch => "master", remote => 'origin', n_ahead => 1);
statusLine('## master...origin/master [ahead 1, behind 1]');
statusLine('## test', "branch"=> 'test');
statusLine('## test...origin/test [gone]', branch => 'test', remote => 'origin', gone=>'gone');
statusLine('## HEAD (no branch)', detachedHead=>1);
#ok(parseStatusLine('failing'), 0);

sub statusLine {
    my $line = shift;
    my %expected = @_;
    my $parsed=parseStatusLine($line);

    return ok($parsed) unless %expected;

    my $unparsedStr;
    my $expectedStr;
    for my $k (keys %expected){
      $unparsedStr .= $k.": ".$parsed->{$k}.', ';
      $expectedStr .= $k.": ".$expected{$k}.', ';
    }

    ok($unparsedStr,$expectedStr)
}
