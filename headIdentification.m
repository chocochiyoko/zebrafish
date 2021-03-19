function realcodebook
    
    %%% ENTER SOURCE FILE TITLE HERE
    vidobj = VideoReader('smallclean.mp4');
    
    %%% ENTER OUTPUT TITLE HERE
    finalvid = VideoWriter('eep.avi');
    finalvid.FrameRate = vidobj.FrameRate;
    open(finalvid);
    
    frames = read(vidobj);
    frameInfo = size(frames);
    height = frameInfo(2);
    width = frameInfo(1);
    pixels = width .* height;
    disp(pixels);
    
    
    %initializing codebook and cache for each pixel
    for w = width:-1:1
        for h = height:-1:1
            for num = 1:6
                book(w .* height + h, num, 1) = -1;  %avg intensity
                book(w .* height + h, num, 2) = 0;  %hi intensity
                book(w .* height + h, num, 3) = 0;  %lo intensity
                book(w .* height + h, num, 4) = 0;  %frequency
                book(w .* height + h, num, 5)= 0;   %MNRL
                book(w .* height + h, num, 6) = 0;  %first occurence
                book(w .* height + h, num, 7) = 0;  %last access
                book(w .* height + h, num, 8) = 0;  %avg dif from pixel avg
                
                %cache indices same as book
                cache(w .* height + h, num, 1) = -1;
                cache(w .* height + h, num, 2) = 0;
                cache(w .* height + h, num, 3) = 0;
                cache(w .* height + h, num, 4) = 0;
                cache(w .* height + h, num, 5)= 0;
                cache(w .* height + h, num, 6) = 0;
                cache(w .* height + h, num, 7) = 0;
                cache(w .* height + h, num, 8) = 0;
            end
            last(w .* height + h, 1) = 0;   %avg pixel intensity
            last(w .* height + h, 2) = 0;   %avg pixel dif
            last(w .* height + h, 3) = 0;
            last(w .* height + h, 4) = 0; 
        end
    end
    
    
    
    %initializing some variables
    avg = 0;
    difneg = 0;
    difpos = 0;
    negcount = 1 ;
    poscount = 1;
    varpos = 0;
    varneg = 0;
    avgmvmnt = 0;
    var = 0;
    lastavg = 128;
     headcount = 0; 
    %training frames
    trainingFrames = 500;                    %%SET TRAINING FRAMES HERE
    for l = 1:trainingFrames
        disp(l);
        temp = frames(:,:,:,l);
        temp = im2gray(temp);
        temp2 = frames(:,:,:,l + 1);
        temp2 = im2gray(temp2);
        %for each pixel
        counter = 0; 
        for w = 1:size(temp,1)
            for h = 1:size(temp,2)
                last = temp(w, h); 
                curr = temp2(w, h);
                if(curr < 100) 
                    counter = double(counter) + double(1); 
                elseif(counter > 0) 
                    backcounter = 1; 
                    if(h-backcounter < 1) 
                        continue; 
                    end 
                    curr = temp2(w, h-backcounter); 
                    while(curr < 100)
                       
                        temp2(w, h-backcounter) = counter; 
                        backcounter = double(backcounter) + double(1);
                         if(h-backcounter < 1) 
                            break; 
                        end 
                        curr = temp2(w, h-backcounter); 
                    end 
                    counter = 0; 
                end 
            end
        end
        for h = 1:size(temp,2)
            for w = 1:size(temp,1)
                last = temp(w, h); 
                curr = temp2(w, h);
                if(curr < 100) 
                    counter = double(counter) + double(1); 
                elseif(counter > 0) 
                    backcounter = 1; 
                    if(w-backcounter < 1) 
                        continue; 
                    end 
                    curr = temp2(w -backcounter, h); 
                    while(curr < 100)
                       
%                         if( abs(double(temp2(w -backcounter, h)) - double(counter)) < 2 && abs(double(temp2(w -backcounter, h)) + double(counter)) > 8)
%                             temp2(w -backcounter, h) = 200; 
%                         end 
                        if( temp2(w -backcounter, h) + counter > 10 &&  temp2(w -backcounter, h) )
                            temp2(w -backcounter, h) = 220; 
                        end 
                      
                        
                        backcounter = double(backcounter) + double(1);
                         if(w-backcounter < 1) 
                            break; 
                        end 
                        curr = temp2(w -backcounter, h); 
                    end 
                    counter = 0; 
                end 
            end
        end
       
        for h = 1:size(temp,2)
            for w = 1:size(temp,1)
                last = temp(w, h); 
                curr = temp2(w, h);
                if(curr == 220) 
                    need = 0; 
                     for h1 = h - 3:h + 3
                        for w1 = w - 3: w + 3
                            if (h1 < 1 || w1 < 1 || h1 > size(temp, 2) - 4 ||  w1 > size(temp, 1) - 4)
                                continue; 
                            end 
                            if (temp2(w1, h1) == 220 || temp2(w1, h1) < 20)
                                need = need + 1; 
                            else
                                break;
                            end 
                        end 
                     end 
                     if (need > 35) 
                         for h1 = h - 3:h + 3
                            for w1 = w - 3: w + 3
                                temp2(w1, h1) = 150;
                            end 
                         end 
                         headcount = double(headcount) + double(1); 
                     end 
                     if (need < 35) 
                         temp2(w, h) = 0;
                         
                     end 
                end 
            end
        end
        imshow(temp2, []);
        writeVideo(finalvid, temp2);
    end 
    disp("avg heads") ;
    disp(headcount/trainingFrames); 
    disp((69 - (headcount/trainingFrames))/69* 100); 
      close(finalvid);
%     filteredvid = VideoReader('eep.avi');
%     filteredframes = read(filteredvid);
%     finalvid2 = VideoWriter('eep2.avi');
%     finalvid2.FrameRate = vidobj.FrameRate;
%     open(finalvid2);
%     for l = 1:trainingFrames
%         disp(l);
%         temp3 = frames(:,:,:,l);
%         temp3 = im2gray(temp3);
%         temp = filteredframes(:,:,:,l);
%         temp = im2gray(temp);
%         %for each pixel
%         for w = 2:size(temp,1) - 1
%             for h = 2:size(temp,2) - 1
%                 filtered = temp; 
%                 original = temp3;
%                 first = original(w - 1, h) < 200; 
%                 second = original(w + 1, h) < 200; 
%                 third= original(w - 1, h + 1) < 200; 
%                 fourth = original(w - 1, h - 1) < 200; 
%                 fifth = original(w + 1, h + 1) < 200; 
%                 sixth = original(w +  1, h - 1) < 200; 
%                 seventh = original(w , h + 1) < 200; 
%                 eighth = original(w , h - 1) < 200; 
%                 first2 = filtered(w - 1, h) == 200; 
%                 second2 = filtered(w + 1, h) == 200; 
%                 third2 = filtered(w - 1, h + 1) == 200; 
%                 fourth2 = filtered(w - 1, h - 1) == 200; 
%                 fifth2 = filtered(w + 1, h + 1) == 200; 
%                 sixth2 = filtered(w +  1, h - 1) == 200; 
%                 seventh2 = filtered(w , h + 1) == 200; 
%                 eighth2 = filtered(w , h - 1) == 200; 
%                 part1 = (first + second + third + fourth + fifth + sixth + seventh + eighth) > 4 && (temp2(w - 1, h - 1) == 100 || temp2(w , h - 1) == 100 || temp2(w - 1, h ) == 100);
%                 part2 = (first2 || second2 || third2 || fourth2 || fifth2|| sixth2 || seventh2 || eighth2) && original(w, h) < 230; 
%                 if(part1 || (filtered(w, h) == 200 && original(w, h) < 200))
%                     temp2(w, h) = 100; 
%                 else 
%                     temp2(w, h) = 255; 
%                 end 
%             end
%         end
%         imshow(temp2, []);
%         writeVideo(finalvid2, temp2);
%     end 
    
  