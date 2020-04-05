package MetaBookMarks::Git;

use Git;
use Try::Tiny;

use MetaBookMarks::Git::Command;

use Exporter qw(import);
 
our @EXPORT = qw(parseStatusLine);


sub repository {
  my $class = shift;
  try {
    my $repo = Git->repository;
    bless {
        repo => $repo
    }, $class
  }
}

sub log {
   my $this = shift;
   my $cmd = $this->openCommand('log', @_);
   if(wantarray){
     my $fh = $cmd->{fh};
     <$fh>
   }else{
     $cmd
   }
}

sub checkout {
  my $this = shift;
  my $cmd = $this->command('checkout','--quiet', @_);
}

sub branch {
  my $this = shift;
  my $cmd = $this->openCommand('status', '-b', '--porcelain');
  parseStatusLine($cmd->readLine())->{branch}
}

sub isDetachedHead {
  my $this = shift;
  my $cmd = $this->openCommand('status', '-b', '--porcelain');
  parseStatusLine($cmd->readLine())->{detachedHead}
}

sub headCommit {
  my $this = shift;
  my $cmd = $this->openCommand('rev-parse', 'HEAD');
  die " ☠️  Twiligh zone \n" if $cmd->eof;
  my $headCommit = $cmd->readLine();
  chomp($headCommit);
  return $headCommit
}


sub isDirty {
  my $this = shift;
  my $cmd = $this->openCommand('status', '--porcelain');
  return $cmd->readLine()
}

sub command {
  my $this = shift;
  $this->{repo}->command(@_)
}


sub openCommand {
  my $this = shift;
  MetaBookMarks::Git::Command->new($this->{repo}, @_)
}



sub parseStatusLine {
    my $line = shift;
    return {
        'branch' => "No commit",
        'icon' => " 🆕 "
    } if $line eq '## No commits yet on master';
    my $branch = '[\w\-]+(?:\.[\w\-]+)*';
    if($line =~ m!^##\s(HEAD \(no branch\))|($branch)(?:\.\.\.($branch)/($branch)(?:\s(?:\[(?:(?:(ahead)\s(\d+))?(?:,\s)?(?:(behind)\s(\d+))?|(gone))?\])?)?)?!){
    #                  ]_________1________[ ]___2___[         ]__ 3 __[ ]__ 4 __[                ]_ 5 _[  ]_6_[             ]___7__[  ]_8_[   ]_ 9_[ 
      if(wantarray){
        if($1){
          return ($1)
        }else{
          return ($2,$3,$4,$5,$6,$7,$8,$9)
        }
      }else{
        if($1){
          {detachedHead=>1}
        }else{
        my $r = {'branch' => $2};
        my $opt = sub {$r->{$_[0]} = $_[1] if $_[1]};
        $opt->('remote', $3);
        $opt->('remote_branch', $4);
        $opt->('is_ahead', $5);
        $opt->('n_ahead', $6);
        $opt->('is_behind', $7);
        $opt->('n_behind', $8);
        $opt->('gone', $9);
#      $opt->('icon'," 💚 ");
        return $r
        }

      }
    }else{
      die "Unparsable ->$line<-"
    }    
}

sub status {
    my $this = shift;
    my ($fh, $ctx) = $$this->openCommand('status', '-b', '--porcelain');
    $this->{fh} = $fh;
    $this->{ctx} = $ctx;
    $fh;
}

1;