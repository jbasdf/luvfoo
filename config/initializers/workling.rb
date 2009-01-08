# Get starling and working going with:
#
# Fire up starling - this isn't in daemon mode.  Add a -d for that.
# starling -P tmp/pids/starling.pid -q tmp/starling 
#
# Next fire up the server
# script/server
#
# Get workling going
# script/workling_starling_client start

# if you comment out the following line all calls will be syncronous - useful for debugging
#Workling::Remote.dispatcher = Workling::Remote::Runners::StarlingRunner.new

#this runner just executes everything normally
#Workling::Remote.dispatcher = Workling::Remote::Runners::NotRemoteRunner.new

