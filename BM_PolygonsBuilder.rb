#!/usr/bin/ruby

#*****************************************************************************************
#
#
#  BoundsGrabber: MainClass
#  © Asity 2013
#
#  version: ß1.00.03
#
#*****************************************************************************************

require "BM_Geometric.rb"


module BoundBuilderModule
    include GeometricClassTools
    
    # + (PolygonClass) (^) (string)
    def makePolygonFromOpenStreetMapDataFile(filepath=nil)
        filepath=makeString(filepath)
        if (!File.exists?(filepath))
            logExit("Filepath doesn't exist (#{filepath})!")
            return
        end
        
        nodes=Array.new
        ways=Array.new
        
        File.readlines(filepath).each do |line|
#puts line
            if (line.index("node,"))
                nodes.push(line.strip.split(',').slice!(1,3))
                
            elsif (line.index("way,"))
                row=line.strip.split(',')
                row.slice!(0)
                ways.push(row)
            end
        end
# nodes.each do |node|
#     puts "#{node[0]},#{node[1]},#{node[2]}"
# end
# puts "------------------"
# ways.each do |way|
#     puts way
#     puts "----"
# end
        data=Array.new
        
        idx=0; type=1; interrupted=0
        while (ways.length!=0)
            way=ways[idx]
#puts way
            if (type==1)
                startIdx=0; endIdx=way.length-1
            else
                startIdx=way.length-1; endIdx=0
            end
#puts "#{way[startIdx]},#{way[endIdx]}"
            
            jdx=startIdx
            while (jdx!=endIdx)
                id=way[jdx]
                nodes.each do |item|
                    if (item[0]==id)
#puts ">>>>"
                        data.push(IdentifiedCoordClass.new("#{item[0]}",item[1].to_f,item[2].to_f))
                        break
                    end
                end
                jdx+=type
            end
            
            endId=way[endIdx]
            ways.slice!(idx)
            type=0; idx=-1
#puts ">#{endId}<"
            for i in 0...ways.length
#puts "#{ways[i][0]},#{ways[i][ways[i].length-1]}"
               if (ways[i][0]==endId)
#puts ">>>>"
                   type=1; idx=i; break
               end
            end
            if (idx==-1)
                if (ways.length==0); break; end
                for i in 0...ways.length
#puts "#{ways[i][0]},#{ways[i][ways[i].length-1]}"
                    if (ways[i][ways[i].length-1]==endId)
#puts ">>>>"
                        type=-1; idx=i; break
                    end
                end
                if (idx==-1)
                    $stderr.puts "          *** end not found"
                    interrupted=1
                    break
                end
            end
        end

#puts data
        if (interrupted==0)
            return PolygonClass.new(data)
        else
           return nil
        end
    
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
        
        puts "Reduction: #{polygon.length}>#{pg.length}"
        
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

    # - (void) (^) (polygon,string)
    def writePolygonToJSONFile(polygon,filepath=nil,varname=nil)
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
        _varname=makeString(varname)
        if (_varname!="")
            file.write("#{_varname}=[")
        else
            file.write("[")
        end
        for i in 0...polygon.length
            line="{\"y\":#{polygon[i].y},\"x\":#{polygon[i].x}}"
            if (i<polygon.length-1); line="#{line},"; end
            file.write(line)
        end
        if (_varname!="")
            file.write("];")
        else
            file.write("]")
        end
        file.close
    end
    
end

class MainClass < BasicClass
    include BoundBuilderModule
    
    def initialize(datafilepath,fullpolygonfilepath,reducedpolygonfilepath)
        _datafilepath=makeString(datafilepath)
        #$stderr.puts _datafilepath
        
        if (fullpolygonfilepath!=nil)
            if (fullpolygonfilepath!='NO')
                _fullpolygonfilepath=makeString(fullpolygonfilepath)
            else
                _fullpolygonfilepath=""
            end
        end
        if (reducedpolygonfilepath!=nil)
            if (reducedpolygonfilepath!='NO')
                _reducedpolygonfilepath=makeString(reducedpolygonfilepath)
            else
                _reducedpolygonfilepath=""
            end
        end

        polygon=makePolygonFromOpenStreetMapDataFile(_datafilepath)
        if (polygon==nil); return; end

        if (_fullpolygonfilepath!="")
            writePolygonToJSONFile(polygon,_fullpolygonfilepath,"fullpolygon")
        end
        
        polygonReduced=makeReducedPolygon(polygon)
        polygon.setSelfBearing
        polygon.setSelfWise(1)
        
        if (_reducedpolygonfilepath!="")
            writePolygonToJSONFile(polygonReduced,_reducedpolygonfilepath,"reducedpolygon")
        end
        
    end
end


if (ARGV[0]!=nil)
    main=MainClass.new(ARGV[0],ARGV[1],ARGV[2])
else
    puts "usage: #{__FILE__} datafilepath fullpolygonfilepath reducedpolygonfilepath"
end





