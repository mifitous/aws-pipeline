#!groovy

import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

println "--> creating local user 'juser'"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('juser','mugpEr-wezny1-vucdab')
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()