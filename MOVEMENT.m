function realcodebook
    
    %%% ENTER SOURCE FILE TITLE HERE
    vidobj = VideoReader('313zebrafish2.avi');
    
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
    stack = java.util.Stack();
    disp(width);
    disp(height); 
    for num = 1:1000
        blob(num, 1) = 0; % size
        blob(num, 2) = width; % min width
        blob(num, 3) = height; % min height
        blob(num, 4) = 0; % max width
        blob(num, 5) = 0; % max height
        blob(num, 6) = 0; % curr fish guess
        blob(num, 7) = 0; % curr fish cost
        blob(num, 8) = 0; %moving X avg
        blob(num, 9) = 0; %moving Y avg
        blob(num, 10) = 0; %frame found
        blob(num, 11) = width; % min width new 
        blob(num, 12) = height; % min height new 
        blob(num, 13) = 0; % max width new 
        blob(num, 14) = 0; % max height new 
        blob(num, 15) = 0;
    end
    for num = 1:200
        fish(num, 1) = 0; % size
        fish(num, 2) = width; % min width
        fish(num, 3) = height; % min height
        fish(num, 4) = 0; % max width
        fish(num, 5) = 0; % max height
        fish(num, 6) = 0; %vx; 
        fish(num, 7) = 0; %vy; 
        fish(num, 8) = 0; %center; 
        fish(num, 9) = 0;
        fish(num, 10) = randi([1, 255],1,1); 
        fish(num, 11) = randi([1, 255],1,1);
        fish(num, 12) = randi([1, 255],1,1); 
    end

    %initializing some variables
   
    trainingFrames = 800;                    %%SET TRAINING FRAMES HERE
    startFrame = 1;
    for l = startFrame:trainingFrames
        disp(l);
        temp = frames(:,:,:,l);
        temp = im2gray(temp);
        temp2 = frames(:,:,:,l + 1);
        temp2 = im2gray(temp2);
        temp3 = frames(:,:,:,l + 1);
        %for each pixel
        counter = 0;  
        currBlob = 21;
      for w = 1:width
          for h = 1:height
              curr = temp2(w, h); 
              last = temp(w, h); 
              if(curr < 20 ) 
                  currBlob = double(currBlob) + double(1); 
                  counter = double(counter) + double(1); 
                  temp2(w, h) = currBlob; 
                  stack.push(w * height + h); 
                  blob(counter, 1) = 0; % size
                  blob(counter, 2) = w; % min width
                  blob(counter, 3) = h; % min height
                  blob(counter, 4) = w; % max width
                  blob(counter, 5) = h; % max height
                  blob(counter, 6) = 0; % curr fish guess
                  blob(counter, 7) = double(9999999); % curr fish cost
                  blob(counter, 8) = 0; %moving X avg
                  blob(counter, 9) = 0; %moving Y avg
                  blob(counter, 10) = l;
                  blob(counter, 11) = w; % min width
                  blob(counter, 12) = h; % min height
                  blob(counter, 13) = w; % max width
                  blob(counter, 14) = h; % max height
                  blob(counter, 15) = 0;
                  
                  
                  while(~stack.empty())
                      curr = stack.pop(); 
                      currW = double(max(1, floor(double(curr) / double(height)))); 
                      currH = double(max(1, floor(mod(curr, height)))); 
                      if(currH+ 1 < height && currW < width && temp2(currW, currH+ 1) < 20) 
                          stack.push(currW * height + currH + 1); 
                          temp2(currW, currH + 1) = currBlob; 
                          blob(counter, 1) = double(blob(counter, 1)) + double(1); % size
                          blob(counter, 5) = double(max(currH + 1, blob(counter, 5)));
                          if (temp(currW, currH+ 1) > 20)
                              blob(counter, 14) = double(max(currH + 1, blob(counter, 14)));
                              blob(counter, 15) = double(blob(counter, 15)) + double(1); % size
                          end 
%                    
                      end 
                      if(currH > 1 && currW < width && temp2(currW, currH -  1) < 20) 
                          stack.push(currW * height + currH - 1);
                          temp2(currW, currH - 1) = currBlob;
                          blob(counter, 3) = double(min(currH - 1, blob(counter, 3)));
                          blob(counter, 1) = double(blob(counter, 1)) + double(1); % size
                          if (temp(currW, currH - 1) > 20)
                              blob(counter, 12) = double(min(currH - 1, blob(counter, 12)));
                              blob(counter, 15) = double(blob(counter, 15)) + double(1);
                          end 
                      end 
                      if(currW < width && currH < height && temp2(currW + 1, currH) < 20) 
                          stack.push((currW + 1) * height + currH);
                         temp2(currW + 1, currH) = currBlob; 
                         blob(counter, 4) = double(max(currW + 1, blob(counter, 4)));
                         blob(counter, 1) = double(blob(counter, 1)) + double(1); % size
                         if (temp(currW + 1, currH) > 20)
                             blob(counter, 13) = double(max(currW + 1, blob(counter, 13)));
                             blob(counter, 15) = double(blob(counter, 15)) + double(1);
                         end 
                      end 
                      if(currW > 1 && currH < height && temp2(currW - 1, currH) < 20) 
                          stack.push((currW - 1) * height + currH); 
                          temp2(currW - 1, currH) = currBlob; 
                          blob(counter, 2) = double(min(currW - 1, blob(counter, 2))); % min width
                          blob(counter, 1) = double(blob(counter, 1)) + double(1); % size
                          if (temp(currW - 1, currH) > 20)
                               blob(counter, 11) = double(min(currW - 1, blob(counter, 11)));
                               blob(counter, 15) = double(blob(counter, 15)) + double(1);
                          end 
                      end 
                  end 
              end 
          end 
      end 
      for blobnum = 1:1000
          if(blob(blobnum, 1) > 60 && blob(blobnum, 10) == l)
              if(l == startFrame) 
                  num = 0; 
                  flag = false; 
                  while (~flag)
                      num = double(num) + double(1); 
                      if (fish(num, 1) == 0) 
                          flag = true; 
                      end 
                  end 
                  fish(num, 1) = double(blob(blobnum, 1)); % size
                  fish(num, 2) = double(blob(blobnum, 2)); % min width
                  fish(num, 3) = double(blob(blobnum, 3)); % min height
                  fish(num, 4) = double(blob(blobnum, 4)); % max width
                  fish(num, 5) = double(blob(blobnum, 5)); % max height
                  fish(num, 6) = 0; %vx; 
                  fish(num, 7) = 0; %vy; 
                  midX = (blob(blobnum, 2) + blob(blobnum, 4))/2; 
                  midY = (blob(blobnum, 3) + blob(blobnum, 5))/2; 
                  fish(num, 8) = midX * height + midY; %center; 
              else
                  for j = 1:200
                      if(fish(j, 1) ~= 0) 
%                            midX = (double(blob(blobnum, 2)) + double(blob(blobnum, 4)))/double(2); 
%                            midY = (double(blob(blobnum, 3)) + double(blob(blobnum, 5)))/double(2); 
%                            distX = abs(double(floor(fish(j, 8)/height)) - double(midX)); 
%                            distY = abs(double(mod(fish(j, 8), double(height))) - double(midY)); 
                            distX = double(blob(blobnum, 2)) - fish(j, 2); 
                            distY = double(blob(blobnum, 3)) - fish(j, 3);
                            distX2 = double(blob(blobnum, 4)) - fish(j, 4); 
                            distY2 = double(blob(blobnum, 5)) - fish(j, 5); 
                           totalDist = (double(distX) * double(distX) + double(distY) * double(distY))^0.5;
                           totalDist = double(totalDist) + (double(distX2) * double(distX2) + double(distY2) * double(distY2))^0.5;
                           sizeRatio = blob(blobnum, 1)/fish(j, 1);  
                           if (totalDist < blob(blobnum, 7) && fish(j, 9) ~= l)
                               blob(blobnum, 6) = double(j); 
                               blob(blobnum, 7) = double(totalDist); 
                           end 
                      end 
                  end 
                  %hello 
                  if(blob(blobnum, 6) == 0)
                      continue; 
                  end 
                  sizeRatio = double(blob(blobnum, 1))/double(fish(blob(blobnum, 6), 1));
                  if(sizeRatio <= 1.6 && sizeRatio >= 0.7) 
%                       disp("fish guess"); 
%                       disp(blob(blobnum, 6)); 
                      midXBlob = (blob(blobnum, 2) + blob(blobnum, 4))/2; 
                      midYBlob = (blob(blobnum, 3) + blob(blobnum, 5))/2;
                      midXFish = (fish(blob(blobnum, 6), 2) + fish(blob(blobnum, 6), 4))/2;
                      midYFish = (fish(blob(blobnum, 6), 3) + fish(blob(blobnum, 6), 5))/2;
                      fish(blob(blobnum, 6), 1) = blob(blobnum, 1); % size
                      fish(blob(blobnum, 6), 2) = blob(blobnum, 2); % min width
                      fish(blob(blobnum, 6), 3) = blob(blobnum, 3); % min height
                      fish(blob(blobnum, 6), 4) = blob(blobnum, 4); % max width
                      fish(blob(blobnum, 6), 5) = blob(blobnum, 5); % max height
                      fish(blob(blobnum, 6), 6) = midXBlob - midXFish; %vx; 
                      fish(blob(blobnum, 6), 7) = midYBlob - midYFish; %vy; 
                      fish(blob(blobnum, 6), 8) = midXBlob * height + midYBlob; %center;
                      fish(blob(blobnum, 6), 9) = l; 
                  elseif(sizeRatio > 1.6)
                      count = 0;
                      for k = 1:200
                          if (fish(k, 1) == 0)
                              continue; 
                          end 
                          distX = double(blob(blobnum, 2)) - fish(k, 2) + fish(k, 6); 
                            distY = double(blob(blobnum, 3)) - fish(k, 3) + fish(k, 7);
                            distX2 = double(blob(blobnum, 4)) - fish(k, 4) + fish(k, 6); 
                            distY2 = double(blob(blobnum, 5)) - fish(k, 5) + fish(k, 7); 
                           totalDist = (double(distX) * double(distX) + double(distY) * double(distY))^0.5;
                           totalDist = double(totalDist) + (double(distX2) * double(distX2) + double(distY2) * double(distY2))^0.5;
                           if (abs(totalDist) < 20)                                                         
                              
                               if (fish(k, 2) + fish(k, 6) > 1 && fish(k, 2) + fish(k, 6) < width) 
                                    fish(k, 2) = floor(fish(k, 2) + fish(k, 6)); % min width
                               end 
                               if (fish(k, 3) + fish(k, 7) > 1 && fish(k, 3) + fish(k, 7) < height)
                                    fish(k, 3) = floor(fish(k, 3) + fish(k, 7)); % min height
                               end 
                               if (fish(k, 4) + fish(k, 6) > 1 && fish(k, 4) + fish(k, 6) < width) 
                                     fish(k, 4) = floor(fish(k, 4) + fish(k, 6)); % max width
                               end 
                               if (fish(k, 5) + fish(k, 7) > 1 && fish(k, 5) + fish(k, 7) < height) 
                                    fish(k, 5) = floor(fish(k, 5) + fish(k, 7)); % max height
                               end 
                              fish(k, 6) = 0; %vx; 
                              fish(k, 7) = 0; %vy; 
                              midX = (blob(blobnum, 11) + blob(blobnum, 13))/2; 
                              midY = (blob(blobnum, 12) + blob(blobnum, 14))/2; 
                              fish(k, 8) = midX * height + midY; %center; 
                              fish(k, 9) = l;
                              count = count + 1; 
                           end 
                          
                      end 
                      if (count > 1) 
                       fish(blob(blobnum, 6), 9) = -1;
                      end 
%                      
                  elseif(sizeRatio < 0.7)
                      fish(blob(blobnum, 6), 9) = -1;
                      num = 0; 
                      flag = false; 
                      while (~flag)
                          num = double(num) + double(1); 
                          if (fish(num, 1) == 0) 
                              flag = true; 
                          end 
                      end 
                      fish(num, 1) = double(blob(blobnum, 1)); % size
                      fish(num, 2) = double(blob(blobnum, 2)); % min width
                      fish(num, 3) = double(blob(blobnum, 3)); % min height
                      fish(num, 4) = double(blob(blobnum, 4)); % max width
                      fish(num, 5) = double(blob(blobnum, 5)); % max height
                      fish(num, 6) = 0; %vx; 
                      fish(num, 7) = 0; %vy; 
                      midX = (blob(blobnum, 2) + blob(blobnum, 4))/2; 
                      midY = (blob(blobnum, 3) + blob(blobnum, 5))/2; 
                      fish(num, 8) = midX * height + midY; %center; 
                      fish(num, 9) = l;
                  end 
                  
              end 
          end 
      end 
      for k = 1:200
          if (fish(k, 9) == -1)
              fish(k, 1) = 0;
          end 
          if (fish(k, 1) == 0)
              continue; 
          end 
          fishwidth = fish(k, 4) - fish(k, 2); 
          fishheight = fish(k, 5) - fish(k, 3); 
          for i = 0:fishwidth
              temp3(fish(k, 2) + i, fish(k, 3), 1) = fish(k, 10); 
              temp3(fish(k, 2) + i, fish(k, 3), 2) = fish(k, 11);
              temp3(fish(k, 2) + i, fish(k, 3), 3) = fish(k, 12);
              temp3(fish(k, 2) + i, fish(k, 5), 1) = fish(k, 10); 
              temp3(fish(k, 2) + i, fish(k, 5), 2) = fish(k, 11); 
              temp3(fish(k, 2) + i, fish(k, 5), 3) = fish(k, 12); 
          end 
          for i = 0:fishheight
              temp3(fish(k, 2), fish(k, 3) + i, 1) = fish(k, 10); 
              temp3(fish(k, 2), fish(k, 3) + i, 2) = fish(k, 11); 
              temp3(fish(k, 2), fish(k, 3) + i, 3) = fish(k, 12); 
              temp3(fish(k, 4), fish(k, 3) + i, 1) = fish(k, 10); 
              temp3(fish(k, 4), fish(k, 3) + i, 2) = fish(k, 11); 
              temp3(fish(k, 4), fish(k, 3) + i, 3) = fish(k, 12); 
          end 
      end 
      
        imshow(temp3, []);
        writeVideo(finalvid, temp3);
    end 
    
      close(finalvid);

    
  