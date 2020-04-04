use strict;

use Test;

BEGIN { plan tests => 8 }

use MetaBookMarks::GitPrompt;

print "#Test GitHelper\n";

ok(parseStatus('## No commits yet on master'));
status('## master', 'branch' => "master");
status('## master...origin/master');
status('## master...origin/master [ahead 1]', branch => "master", remote => 'origin', n_ahead => 1);
status('## master...origin/master [ahead 1, behind 1]');
status('## test', "branch"=> 'test');
status('## test...origin/test [gone]', branch => 'test', remote => 'origin', gone=>'gone');
ok(parseStatus('failing'), 0);



sub status {
    my $line = shift;
    my %expected = @_;
    my $parsed=parseStatus($line);

    return ok($parsed) unless %expected;

    my $unparsedStr;
    my $expectedStr;
    for my $k (keys %expected){
      $unparsedStr .= $k.": ".$parsed->{$k}.', ';
      $expectedStr .= $k.": ".$expected{$k}.', ';
    }

    ok($unparsedStr,$expectedStr)
}
