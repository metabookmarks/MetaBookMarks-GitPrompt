use strict;

use Test;

BEGIN { plan tests => 6, todo => [7] }

use MetaBookMarks::GitPrompt;

print "#Test GitHelper\n";

ok(parseStatus('## No commits yet on master'));
ok(parseStatus('## master')->{branch}, "master");
ok(parseStatus('## master...origin/master'));
ok(parseStatus('## master...origin/master [ahead 1]')->{n_ahead}, 1);
ok(parseStatus('## master...origin/master [ahead 1, behind 1]'));
ok(parseStatus('failing') == 0);

