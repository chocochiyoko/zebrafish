function realcodebook
    
    %%% ENTER SOURCE FILE TITLE HERE
    vidobj = VideoReader('cleanedupshort41.avi');
    
    %%% ENTER OUTPUT TITLE HERE
    finalvid = VideoWriter('contour42beep.avi');
    finalvid.FrameRate = vidobj.FrameRate;
    open(finalvid);
    
    frames = read(vidobj);
    frameInfo = size(frames);
    height = frameInfo(2);
    width = frameInfo(1);
    pixels = width .* height;
    disp(pixels);
    stack = java.util.Stack();
    visited = java.util.Stack(); 
    disp(width);
    disp(height); 
    
    
    trainingFrames = 1700;                    %%SET TRAINING FRAMES HERE
    startFrame = 509;
    for l = startFrame:size(frames,4)
        disp(l);
        temp = frames(:,:,:,l);
        temp = im2gray(temp);
        temp2 = frames(:,:,:,l + 1);
        temp2 = im2gray(temp2);
        temp3 = frames(:,:,:,l + 1);
        %for each pixel
        counter = 0;  
        currBlob = 201;
      for w = 1:width
          for h = 1:height
             if(temp2(w, h) > 200)
                if(temp2(w, min(height, h + 1)) < 200)
                    temp3(w, h, 1) = 0; 
                    temp3(w, h, 2) = 0; 
                    temp3(w, h, 3) = 0; 
                elseif (temp2(w, max(1, h - 1)) < 200) 
                    temp3(w, h, 1) = 0; 
                    temp3(w, h, 2) = 0; 
                    temp3(w, h, 3) = 0; 
                elseif (temp2(min(width, w + 1), h) < 200) 
                    temp3(w, h, 1) = 0; 
                    temp3(w, h, 2) = 0; 
                    temp3(w, h, 3) = 0; 
                elseif (temp2(max(1, w - 1), h) < 200) 
                    temp3(w, h, 1) = 0; 
                    temp3(w, h, 2) = 0; 
                    temp3(w, h, 3) = 0;
%                 elseif (temp2(max(1, w - 1), max(1, h - 1)) < 200) 
%                     temp3(w, h, 1) = 0; 
%                     temp3(w, h, 2) = 0; 
%                     temp3(w, h, 3) = 0;
%                 elseif (temp2(max(1, w - 1), min(height, h + 1)) < 200) 
%                     temp3(w, h, 1) = 0; 
%                     temp3(w, h, 2) = 0; 
%                     temp3(w, h, 3) = 0; 
%                 elseif (temp2(min(width, w + 1), min(height, h + 1)) < 200) 
%                     temp3(w, h, 1) = 0; 
%                     temp3(w, h, 2) = 0; 
%                     temp3(w, h, 3) = 0;
%                 elseif (temp2(min(width, w + 1), max(1, h - 1)) < 200) 
%                     temp3(w, h, 1) = 0; 
%                     temp3(w, h, 2) = 0; 
%                     temp3(w, h, 3) = 0; 
                else     
                    temp3(w, h, 1) = 255;
                    temp3(w, h, 2) = 255;
                    temp3(w, h, 3) = 255;
                end 
             else
                 temp3(w, h, 1) = 255;
                temp3(w, h, 2) = 255;
                temp3(w, h, 3) = 255; 
             end 
          end 
      end 
      
      for w = 1:width
          for h = 1:height
              currW = w; 
              currH = h;
              flag = 0; 
              currRight = 0; 
              currLeft = 0;
              currUp = 0; 
              currDown = 0; 
              flag2 = 0; 
              if(temp3(w, h, 1) > 1)
                  continue; 
              end 
              pointLimit = 30; 
              pointLimit2 = 400; 
              endpoints = zeros(pointLimit); 
              allpoints = zeros(pointLimit2); 
              inflectionPoints = 0; 
              while(flag < 5)
                  
                  %comment out for outline
                   temp3(currW, currH, 1) = 200; 
                    temp3(currW, currH, 2) = 200; 
                    temp3(currW, currH, 3) = 200;
                    counter = 1; 
                    while(1)
                        if(allpoints(counter) == 0)
                            allpoints(counter) = currW * height + currH; 
                            break; 
                        end 
                        counter = double(counter) + double(1); 
                    end 
                    %ok
                    
                    if(temp3(currW, min(height, currH + 1), 1) < 1)
                        currH = min(height, currH + 1); 
                        temp3(currW, currH, 1) = 2;  
                        if(currUp == 0 && currDown > 0)
                            temp3(currW, currH, 2) = 255;
                        end 
                        currUp = currUp + 1;
                        currDown = 0; 
                        
                        
                    elseif (temp3(currW, max(1, currH - 1), 1) < 1) 
                        currH =  max(1, currH - 1); 
                        temp3(currW, currH, 1) = 2; 
                        if(currUp > 0 && currDown == 0)
                           	temp3(currW, currH, 2) = 255;
                    
                        end 
                        currUp = 0;
                        currDown = currDown + 1; 
                        
                    elseif(temp3(min(width, currW + 1), min(height, currH + 1), 1) < 1)
                        currH =  min(height, currH + 1);
                        currW = min(width, currW + 1);
                        temp3(currW, currH, 1) = 2;  
                        if((currUp == 0 && currDown > 0) || (currRight == 0 && currLeft > 2))
                            temp3(currW, currH, 2) = 255;
                        end 
                        currUp = currUp + 1; 
                        currDown = 0; 
                        currRight = currRight + 1;
                        currLeft = 0; 
                        
                    elseif (temp3(min(width, currW + 1), max(1, currH - 1), 1) < 1) 
                        currH = max(1, currH - 1);
                        currW = min(width, currW + 1);
                        temp3(currW, currH, 1) = 2; 
                        if((currUp > 0 && currDown == 0) || (currRight == 0 && currLeft > 0))
                            temp3(currW, currH, 2) = 255;
                        end 
                        currUp = 0;
                        currDown = currDown + 1; 
                        currRight = currRight + 1;
                        currLeft = 0;  
                        
                    elseif(temp3(max(1, currW - 1), min(height, currH + 1), 1) < 1)
                         currH =  min(height, currH + 1);
                         currW = max(1, currW - 1);
                         temp3(currW, currH, 1) = 2; 
                         if((currUp == 0 && currDown > 0) || (currRight > 0 && currLeft == 0))
                            temp3(currW, currH, 2) = 255;
                          
                        end 
                        currUp = currUp + 1; 
                        currDown = 0; 
                        currRight = 0; 
                        currLeft = currLeft + 1; 
                        
                    elseif (temp3(max(1, currW - 1), max(1, currH - 1), 1) < 1)
                        currH =  max(1, currH - 1); 
                        currW = max(1, currW - 1);
                        temp3(currW, currH, 1) = 2;
                        if((currUp > 0 && currDown == 0) || (currRight > 0 && currLeft == 0))
                            temp3(currW, currH, 2) = 255;
                        end 
                        currUp = 0;
                        currDown = currDown + 1;  
                        currRight = 0; 
                        currLeft = currLeft + 1; 
                        
                    elseif (temp3(min(width, currW + 1), currH, 1) < 1) 
                        currW = min(width, currW + 1);
                        temp3(currW, currH, 1) = 2;  
                        if(currRight == 0 && currLeft > 0)
                            temp3(currW, currH, 2) = 255;
                        end 
                        currRight = currRight + 1;
                        currLeft = 0; 
                        
                    elseif (temp3(max(1, currW - 1), currH, 1) < 1) 
                        currW = max(1, currW - 1);
                        temp3(currW, currH, 1) = 2;  
                        if(currRight > 0 && currLeft == 0)
                            temp3(currW, currH, 2) = 255;
                            
                        end 
                        currRight = 0; 
                        currLeft = currLeft + 1; 
                    else 
                        %Big Check
                        
                          temp3(currW, currH, 2) = 255;
%                           flag2= 1; 
                        flag3 = false; 
                        for checkW = currW - 5: currW + 5
                            for checkH = currH - 5: currH + 5
                                if(checkW < 1 || checkW > width || checkH > height || checkH < 1)
                                    break; 
                                end
                                 if(checkW ~= currW && checkH ~= currH && temp3(checkW, checkH, 1) < 1)
                                    temp3(checkW, checkH, 1) = 2;
                                    temp3(checkW, checkH, 2) = 255;
                                    currW = checkW; 
                                    currH = checkH;
                                    flag3 = true; 
                                 end
                                 if(flag3)
                                     break; 
                                 end 
                            end
                            if(flag3)
                                     break; 
                            end 
                        end 
                        if(~flag3)
                            flag = flag + 1; 
                        end 
                      
                    end 
                    if(1)
                        for i = 1:pointLimit
                            if(endpoints(i) == 0 &&  (temp3(currW, currH, 2) == 255 || (currW == w && currH == h)))
                                endpoints(i) = currW * height + currH; 
                                inflectionPoints = inflectionPoints + 1; 
                                break;
                            end 
                        end 
                    end 
              end 
%               disp(inflectionPoints); 
              lineLimit = 20; 
              possibleLine = zeros(lineLimit * 5); 
              P1W = 0; 
              P1H = 0; 
              P2W = 0; 
              P2H = 0; 
              maxDist = 10; 
              
              %find max
              for i = 1:pointLimit
                  for j = 1:pointLimit2
                      W1 = floor(endpoints(i) / height); 
                      H1 = mod(endpoints(i), height);
                      W2 = floor(allpoints(j) / height); 
                      H2 = mod(allpoints(j), height);
                      dist = ((W1 - W2)^2 + (H1 - H2)^2) ^ 0.5;
                       widthLength = double(abs(double(W1 - W2)));
                       heightLength = double(abs(double(H1 - H2)));
                       stepH = double(H2 - H1);
                       stepW = double(W2 - W1);
                       
%                       if( dist > 10 && dist < 35) 
                      if(dist > maxDist && dist < 35)
                          noGood = 0; 
                          if(widthLength > heightLength)
                              
                              step = double(stepH / abs(stepW)); 
                              currentH = double(H1); 
                              currentW = double(W1); 
                              for k = 1:widthLength
                                  currentH = double(currentH) + double(step); 
                                 
                                  if(W1 > W2) 
                                      currentW = max(1, double(currentW) - 1);
                                  else 
                                      currentW = min(width, double(currentW) + 1); 
                                  end 
                                   if(currentH > height || currentH < 1) 
                                      break; 
                                   end 
                                  if(temp2(currentW, floor(currentH)) > 10)
                                        noGood = noGood + 1; 
                                  end 
                              end 
                          else 
                              step = double(stepW / abs(stepH)); 
                              currentW = double(W1); 
                              currentH = double(H1);
                              
                              for k = 1:heightLength
                                  currentW = double(currentW) + double(step);
                                  if(H1 > H2) 
                                      currentH = max(1, double(currentH) - 1);
                                  else 
                                      currentH = min(width, double(currentH) + 1); 
                                  end
                                  if(currentW > width || currentW < 1) 
                                      break; 
                                  end 
                                  if( temp2(floor(currentW), currentH) > 10)
                                        noGood = noGood + 1; 
                                  end 
                              end 
                              
                          end 
                          if(noGood < 5)
                              if(maxDist < dist)
                                maxDist = dist; 
                              end 
                                    possibleLine(1) = W1; 
                                    possibleLine(2) = H1; 
                                    possibleLine(3) = W2; 
                                    possibleLine(4) = H2;
                                    possibleLine(5) = double(abs(W1-W2)/abs(H1-H2)); 
                          end 
                      end 
                      
                  end 
              end 
              %find others              
              for i = 1:pointLimit
                  for j = 1:pointLimit2
                      W1 = floor(endpoints(i) / height); 
                      H1 = mod(endpoints(i), height);
                      W2 = floor(allpoints(j) / height); 
                      H2 = mod(allpoints(j), height);
                      dist = ((W1 - W2)^2 + (H1 - H2)^2) ^ 0.5;
                       widthLength = double(abs(double(W1 - W2)));
                       heightLength = double(abs(double(H1 - H2)));
                       stepH = double(H2 - H1);
                       stepW = double(W2 - W1);
                       
%                       if( dist > 10 && dist < 35) 
                      if(dist > maxDist * 0.65 && dist < 35)
                          noGood = 0; 
                          if(widthLength > heightLength)
                              
                              step = double(stepH / abs(stepW)); 
                              currentH = double(H1); 
                              currentW = double(W1); 
                              for k = 1:widthLength
                                  currentH = double(currentH) + double(step); 
                                 
                                  if(W1 > W2) 
                                      currentW = max(1, double(currentW) - 1);
                                  else 
                                      currentW = min(width, double(currentW) + 1); 
                                  end 
                                   if(currentH > height || currentH < 1) 
                                      break; 
                                   end 
                                  if(temp2(currentW, floor(currentH)) > 10)
                                        noGood = noGood + 1; 
                                  end 
                              end 
                          else 
                              step = double(stepW / abs(stepH)); 
                              currentW = double(W1); 
                              currentH = double(H1);
                              
                              for k = 1:heightLength
                                  currentW = double(currentW) + double(step);
                                  if(H1 > H2) 
                                      currentH = max(1, double(currentH) - 1);
                                  else 
                                      currentH = min(width, double(currentH) + 1); 
                                  end
                                  if(currentW > width || currentW < 1) 
                                      break; 
                                  end 
                                  if( temp2(floor(currentW), currentH) > 10)
                                        noGood = noGood + 1; 
                                  end 
                              end 
                              
                          end 
                          if(noGood < 5)
                              count = 1; 
                              while(true)
%                                   disp(abs(possibleLine(count + 4) - double(abs(W1-W2)/abs(H1-H2))))
                                if(possibleLine(count) ~= 0 && abs(possibleLine(count + 4) - double(abs(W1-W2)/abs(H1-H2))) < 1.5 * possibleLine(count + 4))
                                    break; 
                                end 
                                if(possibleLine(count) == 0)
%                                     disp("koop"); 
                                    possibleLine(count) = W1; 
                                    possibleLine(count + 1) = H1; 
                                    possibleLine(count + 2) = W2; 
                                    possibleLine(count + 3) = H2;
                                    possibleLine(count + 4) = double(abs(W1-W2)/abs(H1-H2)); 
                                    break; 
                                end 
                                count = count + 5; 
                              end
                              break
                          end 
                      end 
                      
                  end 
              end 
              
              %linedraws
              currColor1 = 200;
              currColor2 = 0;
              currColor3 = 100;
              count = 1; 
              for b = 1: lineLimit
                  if(possibleLine(count + 3) == 0)
                      break; 
                  end 
                    P1W = possibleLine(count); 
                    P1H = possibleLine(count + 1); 
                    P2W = possibleLine(count + 2); 
                    P2H = possibleLine(count + 3);
                  widthLength = double(abs(double(P1W - P2W)));
                   heightLength = double(abs(double(P1H - P2H)));
                   stepH = double(P2H - P1H);
                   stepW = double(P2W - P1W);
                   currentH = P1H; 
                   currentW = P1W; 
                    
                  if(widthLength > heightLength)
                       step = double(stepH / abs(stepW)); 
                       for k = 1:widthLength
                          currentH = double(currentH) + double(step); 

                          if(P1W > P2W) 
                              currentW = max(1, double(currentW) - 1);
                          else 
                              currentW = min(width, double(currentW) + 1); 
                          end 
                           if(currentH > height || currentH < 1) 
                              break; 
                           end 
                              temp3(currentW, floor(currentH), 1) = currColor1;
                              temp3(currentW, floor(currentH), 2) = currColor2;
                            temp3(currentW, floor(currentH), 3) = currColor3;
                       end 

                  else 
                          step = double(stepW / abs(stepH)); 

                          for k = 1:heightLength
                              currentW = double(currentW) + double(step);
                              if(P1H > P2H) 
                                  currentH = max(1, double(currentH) - 1);
                              else 
                                  currentH = min(width, double(currentH) + 1); 
                              end
                              if(currentW > width || currentW < 1) 
                                  break; 
                              end 
                                temp3(floor(currentW), currentH, 2) = currColor2;
                                temp3(floor(currentW), currentH, 1) = currColor1;
                                temp3(floor(currentW), currentH, 3) = currColor3;

                          end 

                  end 
                  count = count + 5; 
              end 
          end 
      end 
     
        imshow(temp3, []);
        writeVideo(finalvid, temp3);
    end 
    
      close(finalvid);

    
  