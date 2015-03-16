# popt.sh: popt(3) parameter aliasing for every command

## Usage

Put a `.poptcmd` file into your home directory or into `$PREFIX/etc/poptcmd` along
with the ordinal `.popt` file.

Each line of the file must contain a command alias, a whitespace and the real path
of the command.

For example:

```
psql		/usr/bin/psql
```

Then the `popt.sh` must be symlinked somewhere in the `$PATH` as the name of the
command alias.  In this example:

```
ln -s /usr/local/bin/popt.sh ~/bin/psql
```

When executing `~/bin/psql` `popt.sh` will detect that it invoked as `psql`,
substitutes it's parameters from `~/.popt` and invokes the real command from
`.poptcmd` with the substituted parameters.

Enjoy.
