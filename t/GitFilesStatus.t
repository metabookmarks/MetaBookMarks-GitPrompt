use strict;

use Test;

BEGIN { plan tests => 4 }

use IO::Handle::Util;
use MetaBookMarks::GitPrompt;

fileStatus(["M Staged file"], '🚀');
fileStatus([" M Modified file"], '🚧');
fileStatus(["?? An untracked file"], '👀');
fileStatus(["?? An untracked file", " M Modified file","M Staged file"], '👀', '🚧', '🚀');


sub fileStatus {
  my $lines = shift;
  my @expected = @_;
  my @status = parseFilesStatus({fh=>IO::Handle::Util::io_from_array($lines)});
  
  return ok(join(' ', @status)) unless @expected;

  ok(join(' ', @status), join(' ', @expected));

}