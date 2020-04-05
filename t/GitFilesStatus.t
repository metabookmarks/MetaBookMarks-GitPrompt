use strict;

use Test;

BEGIN { plan tests => 5 }

use IO::Handle::Util;
use MetaBookMarks::GitPrompt;

fileStatus([],'');
fileStatus(["M Staged file"], '🚀');
fileStatus([" M Modified file"], '🚧');
fileStatus(["?? An untracked file"], '👀');
fileStatus(["?? An untracked file", " M Modified file","M Staged file"], '👀', '🚧', '🚀');


sub fileStatus {
  my $lines = shift;
  my @expected = @_;
  my @status = parseFilesStatus({fh=>IO::Handle::Util::io_from_array($lines)});
  
  return ok(join(' ', @status)) unless @expected;
  push @expected, " - " unless join('', @expected) eq '';
  ok(join(' ', @status), join(' ', @expected));
}