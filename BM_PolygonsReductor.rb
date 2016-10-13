#!/usr/bin/ruby

#*****************************************************************************************
#
#
#  PolygonReductor: MainClass
#  © Asity 2013
#
#  version: ß1.00.00
#
#*****************************************************************************************

require "BM_Geometric.rb"


module PolygonReductorModule
    include PolygonClassTools

    # + (PolygonClass) (^) (string)
    def makePolygonFromOpenStreetMapJSON(filepath=nil)
        filepath=makeString(filepath)
        if (!File.exists?(filepath))
            logExit("Filepath doesn't exist (#{filepath})!")
            return
        end
        
        data=Array.new
        cpt=-1
        stat=0
        f=File.open(filepath,'r')
        until f.eof?
            char=f.getc.chr
            if (char=='{' && stat==0)
                stat=1
                elsif (char=='}' && stat==2)
                stat=3
            end
            if (stat==1)
                buffer=""
                stat=2
                elsif (stat==2)
                if (char!='"')
                    buffer<<char
                end
                elsif (stat==3)
                #puts buffer
                if (buffer.index("type:node"))
                    row=Array.new
                    buffer.split(',').slice!(1,3).each do |item|
                        #puts ">#{item}"
                        row.push(item.split(':')[1])
                    end
                    cpt+=1
                    #puts "#{cpt}: #{row[0]}:#{row[1]},#{row[2]}"
                    data.push(IdentifiedCoordClass.new("#{row[0]}",row[1].to_f,row[2].to_f))
                    #break
                end
                stat=0
            end
        end
        f.close
        return PolygonClass.new(data)
    end
    
    # - (void) (^) (polygon,string)
    def writePolygonToOpenStreetMapJSONFile(polygon,filepath=nil)
        if (!polygon.is_a? PolygonClass)
            log("polygon is not a PolygonClass")
            return nil
        end
        if (filepath==nil); return; end
        filepath=makeString(filepath)
        if (filepath==""); return; end
        if (File.exists?(filepath))
            File.delete(filepath)
        end
        file=File.open(filepath,"w")
        #file.write("polygonReduced=[")
        file.write("[")
        
        for i in 0...polygon.length
            line="{\"type\":\"node\",\"id\":#{polygon[i].id},\"lat\":#{polygon[i].lat},\"lon\":#{polygon[i].lng}}"
            if (i<polygon.length-2); line="#{line},"; end
            file.write(line)
        end
        
        file.write("]")
        #file.write("];")
        file.close
    end

    
    # + (PolygonClass) (^) (PolygonClass)
    def makeReducedPolygon(polygon)
        if (!polygon.is_a? PolygonClass)
            log("polygon is not a PolygonClass")
            return nil
        end
        if (polygon.length<=3)
            return polygon
        end
        
        tols=[
        [deg2Rad(45),0.25,0.25],
        [deg2Rad(45),0.25,0.25],
        [deg2Rad(360),10.0,0.02]
        ]
        
        #puts "Base: #{polygon.length}"
        
        pg=polygon.copy
        
        cpt=0
        i=-1
        while i<pg.length
            i+=1
            if (i==pg.length)
                cpt+=1
                i=0
                if (cpt>3)
                    break
                end
                #puts "cpt: #{cpt} #{tols[cpt-1][0]},#{tols[cpt-1][1]},#{tols[cpt-1][2]}"
            end
            
            h=(i==0) ? pg.length-2 : i-1
            j=(i==pg.length-1) ? 0 : i+1
            
            angle1=pg[h].relativeBearing(pg[i])
            angle2=pg[i].relativeBearing(pg[j])
            diff=angle1.abs-angle2.abs
            dist1=pg[h].relativeDistance(pg[i])
            dist2=pg[i].relativeDistance(pg[j])
            
            #puts "   #{h},#{i},#{j}: #{round(angle1,2)} #{round(angle2,2)} (#{round(diff,2)}) #{round(dist1,4)} #{round(dist2,4)}"
            
            if (diff.abs<tols[cpt-1][0] && dist1<tols[cpt-1][1] && dist2<tols[cpt-1][2])
                #puts "     delete: #{i} = #{diff.abs}"
                pg.delete_at(i)
                i-=1
            end
            
            
        end
        
        puts "#{polygon.length}>#{pg.length}"
        
        #Preset Polygon for inside query
        #-get P[0] as lowest y-coordinate
        minYidx=0
        minYvalXval=pg[0].lng
        for i in 1...pg.length
            if (pg[i].lat<pg[minYidx].lat || (pg[i].lat==pg[minYidx].lat && pg[i].lng<pg[minYidx].lng))
                minYidx=i
                minYvalXval=pg[i].lng
            end
        end
        #-make Polygon points rotation to set lowest y to 0 index
        pg2=PolygonClass.new
        for i in minYidx...pg.length
            pg2.push(pg[i])
        end
        for i in 0...minYidx
            pg2.push(pg[i])
        end
        
        return pg2
        
    end
end

class MainClass < BasicClass
    include PolygonReductorModule
    
    def initialize(datafilepath)
        _datafilepath=makeString(datafilepath)
        
        polygon=makePolygonFromOpenStreetMapJSON("#{_datafilepath}")
        
        polygonReducted=makeReducedPolygon(polygon)

        writePolygonToOpenStreetMapJSONFile(polygonReducted,"#{_datafilepath}.reduced")
        
    end
end



if (ARGV[0]!=nil)
    main=MainClass.new(ARGV[0])
else
    puts "usage: #{__FILE__} datafilepath"
end





