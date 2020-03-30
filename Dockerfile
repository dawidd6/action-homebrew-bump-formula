FROM homebrew/brew

COPY main.rb /

ENTRYPOINT ["brew ruby /main.rb"]
