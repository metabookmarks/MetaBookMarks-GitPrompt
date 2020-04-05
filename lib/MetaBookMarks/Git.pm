package MetaBookMarks::Git;

use Git;
use Try::Tiny;

use MetaBookMarks::Git::Command;

sub repository {
  my $class = shift;
  try {
    my $repo = Git->repository;
    bless {
        repo => $repo
    }, $class
  }
}

sub command {
  my $this = shift;
  MetaBookMarks::Git::Command->new($this->{repo}, @_)
}


sub status {
    my $this = shift;
    my ($fh, $ctx) = $this->command('status', '-b', '--porcelain');
    $this->{fh} = $fh;
    $this->{ctx} = $ctx;
    $fh;
}

1;