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
  <$fh>
}

sub close {
  my $this = shift;
  $this->{repo}->command_close_pipe($this->{fh}, $this->{ctx})
}

1;