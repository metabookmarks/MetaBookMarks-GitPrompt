package MetaBookMarks::Git::Command;

sub new {
    my $class = shift;
    my $repo = shift;
    my ($fh, $ctx) = $repo->command_output_pipe(@_);
    my $this = bless {
      repo => $repo,
      fh => $fh,
      ctx => $ctx
    }, $class;

    ($fh, $this)
}

sub readLine {
  my $this = shift;
  my $fh = $this->{fh}; 
  if($this->{repo}->{debug}){
    my $line = <$fh>;
    warn $line."\n";
    $line
  }else{
    <$fh>
  }
}

sub eof { $_[0]->{fh}->eof }

sub close {
  my $this = shift;
  return unless exists $this->{fh};

  my $fh = delete($this->{fh});
  my $ctx = delete($this->{ctx});

  $this->{repo}->command_close_pipe($fh, $ctx);
  return 1
}

sub DESTROY {
  my $this = shift;
  $this->close()
}

1;