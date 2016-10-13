#!/usr/bin/ruby

#*****************************************************************************************
#
#
#  BoundariesManager: GeometricClasses
#  © Asity 2013
#
#  version: ß1.00.03
#
#*****************************************************************************************

require "BM_Basic.rb"

#-----------------------------------------------------------------------------------------
#  GeometricClassTools Module
#-----------------------------------------------------------------------------------------

# (+) tools
module GeometricClassTools
    include BasicClassTools
    
    EARTHRADIUS=6371
    
    # (Float) (^) (Float, Fixnum)
    def round(num,dec)
        _num=makeNumber(num).to_f
        _dec=makeNumber(dec).to_i
        return (_num*(10**dec)).round.to_f/(10**dec)
    end
    
    # (number based on π,-π) (^) (number based on 180°,-180°)
    def deg2Rad(deg=0)
        _deg=makeNumber(deg).to_f
        return _deg*Math::PI/180
    end
    
    # (number based on 180°,-180°) (^) (number based on π,-π)
    def rad2Deg(rad=0)
        _rad=makeNumber(rad).to_f
        return _rad/(Math::PI/180)
    end
    
    # (number based on 2π) (^) (number based on 360°)
    def circDeg2Rad(deg=0)
        _deg=makeNumber(deg).to_f
        return (_deg/360)*2*Math::PI
    end
    
    # (number based on 360°) (^) (number based on 2π)
    def circRad2Deg(rad=0)
        _rad=makeNumber(rad).to_f
        return (_rad/(2*Math::PI))*360
    end
    
    # (PointClass) (^) (PointClass)
    def makePoint(input=PointClass.new,default=PointClass.new)
        if (!input.is_a? PointClass)
            log "#{__method__}: input param not a PointClass (#{input})"
        end
        if (!default.is_a? PointClass)
            log "#{__method__}: default param not a PointClass (#{default})"
            default=PointClass.new
        end
        return (input.is_a? PointClass) ? input : default
    end
    
    # (CoordClass) (^) (CoordClass)
    def makeCoord(input=CoordClass.new,default=CoordClass.new)
        if (!input.is_a? CoordClass)
            log "#{__method__}: input param not a CoordClass (#{input})" 
        end
        if (!default.is_a? CoordClass)
            log "#{__method__}: default param not a CoordClass (#{default})"
            default=CoordClass.new
        end
        return (input.is_a? CoordClass) ? input : default
    end

    # (IdentifiedCoordClass) (^) (IdentifiedCoordClass)
    def makeIdentifiedCoord(input=IdentifiedCoordClass.new,default=IdentifiedCoordClass.new)
        if (!input.is_a? IdentifiedCoordClass)
            log "#{__method__}: input param not a IdentifiedCoordClass (#{input})"
        end
        if (!default.is_a? IdentifiedCoordClass)
            log "#{__method__}: default param not a IdentifiedCoordClass (#{default})"
            default=IdentifiedCoordClass.new
        end
        return (input.is_a? IdentifiedCoordClass) ? input : default
    end
    
    # (CoordClass|IdentifiedCoordClass) (^) (CoordClass|IdentifiedCoordClass)
    def makeBothCoordClassOrIndentifiedCoordClass(input=CoordClass.new,default=CoordClass.new)
        if ((!default.is_a? CoordClass) && (!default.is_a? IdentifiedCoordClass))
            default=makeIdentifiedCoord(default)
        end
        return ((input.is_a? CoordClass) || (input.is_a? IdentifiedCoordClass)) ? input : default
    end
    
end

#-----------------------------------------------------------------------------------------
#  PointClass (BasicClass extend)
#-----------------------------------------------------------------------------------------

class PointClass < BasicClass
    include GeometricClassTools
    
    # (object) (^) (Fixnum|Float|void, Fixnum|Float|void)
    def initialize(x=0,y=0)
        _x=makeNumber(x)
        _y=makeNumber(y)
        @self={'x'=>_x,'y'=>_y}
        logInit
    end
    
    # (-) public classes
    
    def to_s; "{x:#{@self['x']},y:#{@self['y']}}"; end
    
    def x; @self['x']; end
    def y; @self['y']; end
    
    # (Boolean) (^) (PointClass)
    def is_equal?(dot)
        _dot=makePoint(dot)
        return ((_dot.x==self.x) && (_dot.y==self.y))
    end
    
    # (Float) (^) (PointClass)
    def relativeBearing(dot)
        _dot=makePoint(dot)
        if (self.is_equal?(_dot))
            return 0
        end
        return (!self.is_equal?(_dot)) ? Math::atan( (_dot.y-self.y) / (_dot.x-self.x) ) : 0
    end
    
    # (Float) (^) (PointClass)
    def relativeCircularBearing(dot)
        _dot=makePoint(dot)
        if (self.is_equal?(_dot))
            return 0
        end
        dX=_dot.x-self.x
        dY=_dot.y-self.y
        aTgt=Math::atan(dY/dX);
        if (dX<0 && dY<0)
            return Math::PI+aTgt.abs
        elsif (dX<0)
            return Math::PI-aTgt.abs
        elsif (dY<0)
            return (Math::PI*2)-aTgt.abs
        else
            return aTgt.abs
        end
    end
    
    # (Float) (^) (PointClass)
    def relativeDistance(dot)
        _dot=makePoint(dot)
        if (self.is_equal?(_dot))
           return 0
        end
        _x=_dot.x-self.x
        _y=_dot.y-self.y
        return Math::sqrt(_x**2+_y**2)
    end
    
end


#-----------------------------------------------------------------------------------------
#  CoordClass (BasicClass extend)
#-----------------------------------------------------------------------------------------

class CoordClass < BasicClass
    include GeometricClassTools
    
    # (object) (^) (Fixnum|Float|void, Fixnum|Float|void)
    def initialize(lat=0,lng=0)
        _lat=makeNumber(lat).to_f
        _lng=makeNumber(lng).to_f
        @self={'lat'=>_lat,'lng'=>_lng}
        logInit
    end
    
    # (-) public classes
    
    def to_s; "{lat:#{@self['lat']},lng:#{@self['lng']}}"; end
    
    def lat; @self['lat']; end
    def y; @self['lat']; end
    def lng; @self['lng']; end
    def x; @self['lng']; end

    # (Boolean) (^) (CoordClass)
    def is_equal?(dot)
        _dot=makeCoord(dot)
        return ((_dot.lat==self.lat) && (_dot.lng==self.lng))
    end
    
    # (Float) (^) (CoordClass)
    def relativeBearing(dot)
        _dot=makeCoord(dot)
        if (!self.is_equal?(_dot))
            return Math::atan( (deg2Rad(_dot.lat)-deg2Rad(self.lat)) / (deg2Rad(_dot.lng)-deg2Rad(self.lng)) )
        else
            return 0
        end
    end

    # (Float) (^) (CoordClass)
    def relativeCircularBearing(dot)
        _dot=makeCoord(dot)
        if (self.is_equal?(_dot))
            return 0
        end
        dLng=deg2Rad(_dot.lng-self.lng)*Math::cos(deg2Rad((_dot.lng-self.lng)/2))
        dLat=deg2Rad(_dot.lat-self.lat)
        aTgt=Math::atan(dLat/dLng);
        if (dLng<0 && dLat<0)
            return Math::PI+aTgt.abs
        elsif (dLng<0)
            return Math::PI-aTgt.abs
        elsif (dLat<0)
            return (Math::PI*2)-aTgt.abs
        else
            return aTgt.abs
        end
    end
    
    # (Float) (^) (CoordClass)
    def relativeDistance(dot)
        _dot=makeCoord(dot)
        if (self.is_equal?(_dot))
            return 0
        end
        lng=deg2Rad(_dot.lng-self.lng)*Math::cos(deg2Rad((_dot.lng-self.lng)/2))
        lat=deg2Rad(_dot.lat-self.lat)
        return Math::sqrt(lng**2+lat**2)*EARTHRADIUS;
    end
    
end
    

#-----------------------------------------------------------------------------------------
#  IdentifiedCoordClass (CoordClass extend)
#-----------------------------------------------------------------------------------------

class IdentifiedCoordClass < CoordClass
    include GeometricClassTools
    
    # (object) (^) (String|void, Fixnum|Float|void, Fixnum|Float|void)
    def initialize(id="",lat=0,lng=0)
        _id=makeString(id)
        _lat=makeNumber(lat).to_f
        _lng=makeNumber(lng).to_f
        @self={'id'=>_id,'lat'=>_lat,'lng'=>_lng}
        logInit
    end
    
    # (-) public classes
    
    def to_s; "{id:#{@self['id']},lat:#{@self['lat']},lng:#{@self['lng']}}"; end
    
    def id; @self['id'] end
    
    # (Boolean) (^) (CoordClass|IdentifiedCoordClass)
    def is_equal?(dot)
        _dot=makeBothCoordClassOrIndentifiedCoordClass(dot)
        return ((_dot.lat==self.lat) && (_dot.lng==self.lng))
    end
    
    # (Float) (^) (CoordClass|IdentifiedCoordClass)
    def relativeBearing(dot)
        _dot=makeBothCoordClassOrIndentifiedCoordClass(dot)
        _self=CoordClass.new(self.lat,self.lng)
        return _self.relativeBearing(CoordClass.new(_dot.lat,_dot.lng))
    end
    
    # (Float) (^) (CoordClass|IdentifiedCoordClass)
    def relativeCircularBearing(dot)
        _dot=makeBothCoordClassOrIndentifiedCoordClass(dot)
        _self=CoordClass.new(self.lat,self.lng)
        return _self.relativeCircularBearing(CoordClass.new(_dot.lat,_dot.lng))
    end
    
    # (Float) (^) (CoordClass|IdentifiedCoordClass)
    def relativeDistance(dot)
        _dot=makeBothCoordClassOrIndentifiedCoordClass(dot)
        _self=CoordClass.new(self.lat,self.lng)
        return _self.relativeDistance(CoordClass.new(_dot.lat,_dot.lng))
    end
    
end


#-----------------------------------------------------------------------------------------
#  PolygonClass (BasicClass extend)
#-----------------------------------------------------------------------------------------

class PolygonClass < BasicClass
    include BasicClassTools
    
    # (object) (^) (array of PointClass, CoordClass or IdentifiedCoordClass or void)
    #               array first item set the polygon type. Default is PointClass
    def initialize(array=[])
        array=makeArray(array)
        @self=Array.new
        cpt=-1
        @type=nil
        array.each do |item|
            cpt+=1
            if (@type==nil)
                if ((!item.is_a? PointClass) && (!item.is_a? CoordClass) && (!item.is_a? IdentifiedCoordClass))
                    logInit("item #{cpt} (#{item}) not a valid allowed class!")
                    item=PointClass.new
                end
                @type=item.class
            elsif
                if (!item.is_a? @type)
                    logInit("item #{cpt} (#{item}) not of this polygon point class (#{@type})!")
                    case @type
                        when PointClass
                            item=PointClass.new
                        when CoordClass
                            item=CoordClass.new
                        when IdentifiedCoordClass
                            item=IdentifiedCoordClass
                    end
                end
            end
            @self.push(item)
        end
        logInit
    end
    
    # (-) public classes
    
    def to_s
        buffer='{'
        for i in 0...@self.length
            buffer<<"#{@self[i]}"
            if (i<@self.length-1)
                buffer<<','
            end
        end
        buffer<<'}'
        buffer
    end
    
    def type; @type; end
    
    def copy
        array=Array.new
        @self.each { |item|
            array.push(item)
        }
        return PolygonClass.new(array)
    end
    
    def perimeter
        sum=0.0
        #i=-1; while i<@self.length-2; i+=1
        for i in 0...@self.length-1
            dist=@self[i].relativeDistance(@self[i+1])
            #puts "#{i}: #{@self[i].lat},#{@self[i].lng} : #{dist}"
            sum+=dist
            #break
        end
        dist=@self.last.relativeDistance(@self.first)
        #puts "#{i}: #{@self.last.lat},#{@self.last.lng} : #{dist}"
        sum+=dist
        return sum
    end
    
    def setSelfBearing
        minYidx=0
        minYvalXval=@self[0].x
        for i in 0...@self.length
            if (@self[i].y<@self[minYidx].y || (@self[i].y==@self[minYidx].y && @self[i].x<@self[minYidx].x))
                minYidx=i
                minYvalXval=@self[i].x
            end
        end
        array=Array.new
        for i in minYidx...@self.length
            array.push(@self[i])
        end
        for i in 0...minYidx
            array.push(@self[i])
        end
        @self=array;
    end
    
    def exoCentre
        sumX=0; sumY=0
        @self.each do |dot|
            sumX+=dot.x
            sumY+=dot.y
        end
        avgX=sumX/@self.length
        avgY=sumY/@self.length
        if (@type==PointClass)
            return PointClass.new(avgX,avgY)
        elsif (@type==CoordClass)
            return CoordClass.new(avgY,avgX)
        elsif (@type==IdentifiedCoordClass)
            return IdentifiedCoordClass.new("",avgY,avgX)
        end
    end
    
    def rotationWise?
        center=self.exoCentre
        res=0;
        prevBearing=center.relativeCircularBearing(@self[0])
        for i in 1...@self.length+1
            idx=(i<@self.length)?i:0
            curBearing=center.relativeCircularBearing(@self[idx])
            res+=((curBearing-prevBearing)>=0)?1:-1
            prevBearing=curBearing
        end
        if (res>0)
            return -1
        elsif (res<0)
            return 1
        else
            return 0
        end
     end
    
    def setSelfWise (wise)
        _wise=makeNumber(wise)
        _wise=(_wise!=-1 && _wise!=1)?1:_wise
        if (self.rotationWise?!=_wise)
            array=Array.new
            idx=@self.length-1
            while (idx>=0)
                array.push(@self[idx])
                idx-=1
            end
            @self=array
        end
    end
end








