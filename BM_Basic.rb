#!/usr/bin/ruby

#*****************************************************************************************
#
#
#  BoundariesManager: BasicClass
#  © Asity 2013
#
#  version: ß1.00.03
#
#*****************************************************************************************

# (-) skeleton
class BasicClass
    @@logInit=0
    @@log=1
    
    # (-) commons
    attr_accessor :self
    
    def method_missing(*args,&blk)
        @self.send(*args,&blk)
    end

    def to_s; @self; end
    
    def description; "#{self.to_s}"; end
    
    # (-) tools
    
    def log(value="")
        if (@@log==1)
            puts "#{self.class.name}> #{value}"
        end
    end
    
    def logInit(value=description)
        if (@@logInit==1)
            puts "#{self.class.name}/init> #{value}"
        end
    end
    
    def logExit(value=description)
        self.log("#{value} Exiting!")
        exit
    end
end

# (+) tools
module BasicClassTools
    # + (Float|Fixnum) (^) (Float|FixNum|void [,Float|FixNum|void])
    def makeNumber(input=0,default=0)
        if ((!input.is_a? Fixnum) && (!input.is_a? Float))
            log "#{__method__}: input param not a Fixnum or Float (#{input})"
        end
        if ((!default.is_a? Fixnum) && (!default.is_a? Float))
            log "#{__method__}: default param not a Fixnum or Float (#{default})"
            default=0
        end
        return ((input.is_a? Fixnum) || (input.is_a? Float)) ? input : default
    end
    
    # + (Float|Fixnum) (^) (Float|FixNum|void [,Float|FixNum|void])
    def makePositiveNumber(input=0,default=0)
        result=makeNumber(input,default)
        return (result<0) ? -result : result
    end
    
    # + (String) (^) (String|void)
    def makeString(input="",default="")
        if (!input.is_a? String)
            log "#{__method__}: input param not a String (#{input})"
        end
        if (!default.is_a? String)
            log "#{__method__}: default param not a String (#{default})"
            default=""
        end
        return (input.is_a? String) ? input : default
    end
    
    # + (Array) (^) (Array|void)
    def makeArray(input=[],default=[])
        if (!input.is_a? Array)
            log "#{__method__}: input param not an Array (#{input})"
        end
        if (!default.is_a? Array)
            log "#{__method__}: default param not an Array (#{default})"
            default=[]
        end
        return (input.is_a? Array) ? input : default
    end
    
end


