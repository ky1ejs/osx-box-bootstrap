step-agent-go
=============

step agent rewrite in go


## Purpose of this tool

This tool is meant to be a "command receiver", designed to
perform [StepLib](http://www.steplib.com/) steps on a remote
host, mostly through SSH.


## How it works

To make it easier to send complex parameters for the remote command
and to simplify the control of Environment Variable expansion
in paths and parameters (meaning: easier control over where
the Environment Variable expansion happens, on the host or on the remote
end) this tool expects all of it's inputs in Base64 encoded form.

Environment variable pairs are specified the following way (the key
and value of a pair is separated with a dot, and key-value pairs
are separated with a comma):

    key1-base64-encoded.value1-base64-encoded,key2-base64-encoded.value2-base64-encoded

**For example** to run a script on the remote end, where the
script is located at `${HOME}/my_script.sh` (HOME: the home folder
path *on the remote end*) with two environment variable pairs specified for
the script, for example `MYVAR1=first` and `MYVAR2=second`, you can
call this tool:

    step_agent_osx -steppath="JHtIT01FfS9teV9zY3JpcHQuc2g=" -stepenvs=TVlWQVIx.Zmlyc3Q=,TVlWQVIy.c2Vjb25k


## Release:

To create a new release:

1. bump version in `version.go`
2. commit
3. run `$ bash release_test.sh`
4. if prints an error fix it, and run it again while you get an error
5. tag the new release in git
