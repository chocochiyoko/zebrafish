function realcodebook
    
    %%% ENTER SOURCE FILE TITLE HERE
    vidobj = VideoReader('otherfish.mp4');
    
    %%% ENTER OUTPUT TITLE HERE
    finalvid = VideoWriter('zebrafishresult.avi');
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
    
    %training frames
    trainingFrames = 50;                    %%SET TRAINING FRAMES HERE
    for l = 1:trainingFrames
        disp(l);
        temp = frames(:,:,:,l);
        temp = rgb2gray(temp);
        totalmvmnt = 1;
        mvmntcount = 0;

        %for each pixel
        for w = 1:size(temp,1)
            for h = 1:size(temp,2)
                curr = temp(w, h);

                %record averages and difs for next frame
                avg = double(avg) + double(curr);
                if (l == 1)
                    last(w .* height + h, 1) = curr;
                end
                if (curr < lastavg)
                    difneg = double(difneg) + double((lastavg - curr));
                    negcount = double(negcount) + double(1);
                elseif(curr > lastavg)
                    difpos = double(difpos) + double((curr - lastavg)) ;
                    poscount = double(poscount) + double(1);
                else
                end

                %calculate movement
                if (curr >  last(w .* height + h, 1))
                    thisdif = curr -  last(w .* height + h, 1);
                    if(thisdif > last(w .* height + h, 2))
                        mvmnt = (thisdif - last(w .* height + h, 2 )); %movesmore
                    else
                        mvmnt = last(w .* height + h, 2 ) - thisdif;  %movesless
                    end
                    last(w .* height + h, 2) = double(double(double(double(last(w .* height + h, 2)) * double(double(l) - double(1))) + double(thisdif)) / double(l));
                    last(w .* height + h, 3) = double(double(double(double(last(w .* height + h, 3)) * double(double(l) - double(1))) + double(mvmnt)) / double(l));
                else
                    thisdif =  last(w .* height + h, 1) - curr;
                    if(thisdif > last(w .* height + h, 2))
                        mvmnt = (thisdif - last(w .* height + h, 2 )); %movesmore
                    else
                        mvmnt = last(w .* height + h, 2 ) - thisdif;  %movesless
                    end
                    last(w .* height + h, 2) = double(double(double(double(last(w .* height + h, 2)) * double(double(l) - double(1))) + double(thisdif)) / double(l));
                    last(w .* height + h, 3) = double(double(double(double(last(w .* height + h, 3)) * double(double(l) - double(1))) + double(mvmnt)) / double(l));
                end
                if(mvmnt > 0)
                    totalmvmnt = double(totalmvmnt) + double(mvmnt);
                    mvmntcount = double(mvmntcount) + double(1);
                end

                flag = 0;
                found = 0;
                %until pixel is found or added
                for index = 1: 6
                    
                    %add if necessary
                    if (found == 0 && book(w .* height + h, index, 1) == -1) 
                        book(w .* height + h, index, 1) = curr; 
                        book(w .* height + h, index, 2) = curr; 
                        book(w .* height + h, index, 3) = curr; 
                        book(w .* height + h, index, 4) = 1;    
                        book(w .* height + h, index, 5) = 0;  
                        book(w .* height + h, index, 6) = l;   
                        book(w .* height + h, index, 7) = l;  
                        book(w .* height + h, index, 8) = 0;
                        flag = 2;
                        break;
                    end

                    %find alpha and beta
                    if (curr >  book(w .* height + h, index, 1))
                        thisdif = curr -   book(w .* height + h, index, 1);
                        forvar = double(double(thisdif)/(double( varpos)));
                        
                    else
                        thisdif =  book(w .* height + h, index, 1) - curr;
                        forvar = double(double(thisdif)/(double(  varneg)));
                        
                    end
                    alpha = double(forvar);
                    beta = max(1, double(2 -  forvar));
                    
                    %check conditions for matching codeword and update if 
                    %found
                    if (curr > alpha .*  book(w .* height + h, index, 2) && curr< min(book(w .* height + h, index, 3)./alpha ,beta .*  book(w .* height + h, index,2)) )
                        flag = 1;
                        book(w .* height + h, index, 1) = double(double(book(w .* height + h, index, 1) .* double(book(w .* height + h, index, 4))) + double(curr))./double(double(book(w .* height + h, index, 4)) + double(1)) ;
                        book(w .* height + h, index, 8) = double(double(book(w .* height + h, index, 8) .* double(book(w .* height + h, index, 4))) + double(mvmnt))./double(double(book(w .* height + h, index, 4)) + double(1)) ;
                        book(w .* height + h, index, 2) =max(curr,  book(w .* height + h, index, 2)) ;
                        book(w .* height + h, index, 3) = min(curr, book(w .* height + h, index, 3));
                        book(w .* height + h, index, 4) = double (book(w .* height + h, index, 4) + double(1));
                        book(w .* height + h, index, 7) = double(l);    %last  access
                        found = 1;
                        
                    else
                        book(w .* height + h, index, 5) = double(max(book(w .* height + h, index, 5), l - book(w .* height + h, index, 7)));
                    end
                end
                last(w .* height + h, 1) = double(double(double(double(last(w .* height + h, 1)) * double(double(l) - double(1))) + double(curr)) / double(l));

                %set pixel val
                if (flag == 1)
                    temp(w, h) = 255;
                elseif(flag ==2)
                    temp (w, h) = 125;
                elseif(flag == 3)
                    temp(w, h) = 200;
                else
                    temp(w, h) = 0;
                end
                last(w .* height + h, 4) = curr; 
            end
        end
        
        %set and reset values for next frame
        lastavg = double(double(double(lastavg) * double(double(l) - double(1)) + double(double(avg)./ double(pixels))) / double(l));
        varpos = double(double(double(double(varpos) * (double(double(l) - double(1))) + (double(double(difpos))./ double(poscount)))) / double(l));
        varneg = double(double(double(double(varneg) * (double(double(l) - double(1))) + (double(double(difneg))./ double(negcount)))) / double(l));
        avgmvmnt = double(double(double(double(avgmvmnt) * (double(double(l) - double(1))) + (double(double(totalmvmnt))./ double(max(1, mvmntcount))))) / double(l));
        dif = 0;
        avg = 0;
        difpos = 0;
        difneg = 0;
        poscount = 1;
        negcount = 1;

        %show and write frame
        imshow(temp, []);
        writeVideo(finalvid, temp);
    end

    %Trimming, using arbitrary value for now
    for w = width:-1:1
        for h = height:-1:1
            for num = 1:6
%                 if(book(w.* height + h, num, 1) > -1 && book(w.* height + h, num, 5) > trainingFrames./2)
%                     book(w .* height + h, num, 1) = -1;
%                 end
            end
        end
    end

    %Reglar phase
    for l = trainingFrames:size(frames,4)
        
        temp = frames(:,:,:,l);
        temp = rgb2gray(temp);
        totalmvmnt = 0;
        mvmntcount = 0;
       
        %for each pixel 
        for w = 1:size(temp,1)
            for h = 1:size(temp,2)
                curr = temp(w, h);

                %find avg and difs for next frame
                avg = double(avg) + double(curr);
                if (curr < lastavg)
                    difneg = double(difneg) + double((lastavg - curr));
                    negcount = double(negcount) + double(1);
                elseif(curr > lastavg)
                    difpos = double(difpos) + double((curr - lastavg)) ;
                    poscount = double(poscount) + double(1);
                end

                %find movement
                if (curr >  last(w .* height + h, 1))
                    thisdif2 = curr -  last(w .* height + h, 1);
                    if(thisdif2 > last(w .* height + h, 2))
                        mvmnt = (thisdif2 - last(w .* height + h, 2 )); %movesmore
                    else
                        mvmnt = last(w .* height + h, 2 ) - thisdif2;  %movesless
                    end
                    last(w .* height + h, 2) = double(double(double(double(last(w .* height + h, 2)) * double(double(l) - double(1))) + double(thisdif2)) / double(l));
                    last(w .* height + h, 3) = double(double(double(double(last(w .* height + h, 3)) * double(double(l) - double(1))) + double(mvmnt)) / double(l));
                else
                    thisdif2 =  last(w .* height + h, 1) - curr;
                    if(thisdif2 > last(w .* height + h, 2))
                        mvmnt = (thisdif2 - last(w .* height + h, 2 )); %movesmore
                    else
                        mvmnt = last(w .* height + h, 2 ) - thisdif2;  %movesless
                    end
                    last(w .* height + h, 2) = double(double(double(double(last(w .* height + h, 2)) * double(double(l) - double(1))) + double(thisdif2)) / double(l));
                    last(w .* height + h, 3) = double(double(double(double(last(w .* height + h, 3)) * double(double(l) - double(1))) + double(mvmnt)) / double(l));
                end
                if (mvmnt > 0) 
                totalmvmnt = double(totalmvmnt) + double(mvmnt);
                mvmntcount = double(mvmntcount) + double(1);
                end 
                
                flag = 0;
                foundcache = 0;
                mvmntcount2 = 0; 
                minmvmnt = 0;
                maxmvmnt = 0;
                maxmvmntcount = 0;
            
                %find max mvnt in cache
                for index = 1: 6
                    for index = 1: 6
                    if (cache(w .* height + h, index, 1) == -1) 
                        continue; 
                    end 
                    maxmvmnt = max(maxmvmnt +  cache(w.* height + h, index, 8));
                    maxmvmntcount = maxmvmntcount + 1; 
                end
                maxmvmnt = double(double(maxmvmnt) / double(maxmvmntcount)); 
                end
                empty = 0; 
                %for each codeword
                for index = 1: 6
                    if (book(w .* height + h, index, 1) == -1)
                    empty = empty + 1; 
                    %add to codebook if there are no codewords
                    if (empty == 6) 
                        book(w .* height + h, index, 1) = curr; 
                        book(w .* height + h, index, 2) = curr; 
                        book(w .* height + h, index, 3) = curr; 
                        book(w .* height + h, index, 4) = 1;    
                        book(w .* height + h, index, 5) = 0;  
                        book(w .* height + h, index, 6) = l;   
                        book(w .* height + h, index, 7) = l;
                        book(w .* height + h, index, 8) = 0;  
                        flag = 3;
                        break;
                    end
                        continue;
                    end
                    if (book(w .* height + h, index, 1) ~= -1)
                        minmvmnt = double(book(w .* height + h, index, 8) * (book(w .* height + h, index, 4)) +  double(minmvmnt));
                        mvmntcount2 = double(mvmntcount2) + double(book(w .* height + h, index, 4)); 
                    end 
    
                        if (flag ~= 3 && book(w.* height + h, index, 1) > -1 &&   ( l - book(w.* height + h, index, 6)) - book(w.* height + h, index, 4) > book(w.* height + h, index, 4) && book(w.* height + h, index, 8) * book(w.* height + h, index, 5)^0.5 > last(w.*height + h, 3) + 1) 
                        
                        book(w .* height + h, index, 1) = -1; %curr bg
                        flag = 2;
                        continue;
                    end

                    %find alpha and beta
                    if (curr >  book(w .* height + h, index, 1))
                        thisdif = curr -  book(w .* height + h, index, 1);
                        forvar = double(double(thisdif)/(double( varpos )));
                        forvar2 = double(double(thisdif)/(double( varpos + varneg )));
                        
                        
                    else
                        thisdif =  book(w .* height + h, index, 1) - curr;
                        forvar = double(double(thisdif)/(double( varneg)));
                        forvar2 = double(double(thisdif)/(double( varpos + varneg )));
                        
                    end
                    alpha = double(forvar);
                    beta = double(2 -  forvar);
                    alpha2 = double(forvar2);
                    beta2 = double(2 -  forvar2);
                    
                    %check pixel against codeword and update if it matches
                    if (curr>= (alpha .*  book(w .* height + h, index, 2)) && curr <= (min(book(w .* height + h, index, 3)./alpha,  min(book(w .* height + h, index, 2) .*beta))))
                        flag = 1;
                        book(w .* height + h, index, 1) = double(double(book(w .* height + h, index, 1) .* double(book(w .* height + h, index, 4))) + double(curr))./double(double(book(w .* height + h, index, 4)) + double(1)) ;
                        book(w .* height + h, index, 2) =max(curr,  book(w .* height + h, index, 2)) ;
                        book(w .* height + h, index, 3) = min(curr, book(w .* height + h, index, 3));
                        book(w .* height + h, index, 8) = double(double(book(w .* height + h, index, 8) .* double(book(w .* height + h, index, 4))) + double(mvmnt))./double(double(book(w .* height + h, index, 4)) + double(1)) ;
                        book(w .* height + h, index, 4) = double (book(w .* height + h, index, 4) + double(1));
                      
                        book(w .* height + h, index, 7) = l;
                    elseif (( l - book(w .* height + h, index, 6)) - book(w .* height + h, index, 4)/2  > book(w .* height + h, index, 4) &&curr>= (alpha2 .*  book(w .* height + h, index, 2)) && curr <= (min(book(w .* height + h, index, 3)./alpha2,  min(book(w .* height + h, index, 2) .*beta2))))
                        flag = 1;
                        book(w .* height + h, index, 1) = curr;
                        book(w .* height + h, index, 2) = curr; 
                        book(w .* height + h, index, 3) = curr; 
                        book(w .* height + h, index, 8) = double(double(book(w .* height + h, index, 8) .* double(book(w .* height + h, index, 4))) + double(mvmnt))./double(double(book(w .* height + h, index, 4)) + double(1)) ;
                        book(w .* height + h, index, 4) = double (book(w .* height + h, index, 4) + double(1));
                        book(w .* height + h, index, 7) = l;
                    else
                        book(w .* height + h, index, 5) = max(book(w .* height + h, index, 5), l - book(w .* height + h, index, 7));
                    end
                end
                last(w .* height + h, 1) = double(double(double(double(last(w .* height + h, 1)) * double(double(l) - double(1))) + double(curr)) / double(l));
                 minmvmnt = double(double(minmvmnt + 1) / double(mvmntcount2)); 
                %set pixels
                tempcurr = curr; 
                if (flag == 1)
                    temp(w, h) = 255;
                elseif(flag ==2)
                    temp (w, h) = 100;
                elseif(flag ==3) 
                        temp(w, h) = 200; 
                else
                    temp(w, h) = 0;
                    %if it's a foreground
                    %cycle through all cache entries
                    for index2 = 1: 6
                        if (cache(w .* height + h, index2, 5) >  cache(w .* height + h, index2, 4) && (l - cache(w .* height + h, index2, 6))/3 > 20)
                            cache(w .* height + h, index2, 1) = -1;
                            continue;
                        end

                        if (cache(w .* height + h, index2, 1) > last(w .* height + h, 1))
                            difcheck = cache(w .* height + h, index2, 1) -  last(w .* height + h, 1); 
                        else 
                            difcheck = last(w .* height + h, 1) - cache(w .* height + h, index2, 1); 
                        end 
                            if (cache(w .* height + h, index2, 1) ~= -1 && (cache(w .* height + h, index2, 4) > 10 && (difcheck < min(varpos + varneg) && cache(w .* height + h, index2, 8)/ (1 + (cache(w .* height + h, index2, 4)/ l))< minmvmnt + 1)))
                         
                            foundcache = 1;
                            leastfreq = l; 
                            for index4 = 1: 6
                                leastfreq = min(book(w .* height + h, index4, 4), leastfreq); 
                                if (book(w .* height + h, index4, 1) == -1)
                                    book(w .* height + h, index4, 1) = cache(w .* height + h, index2, 1);
                                    book(w .* height + h, index4, 2) = cache(w .* height + h, index2, 2);
                                    book(w .* height + h, index4, 3) = cache(w .* height + h, index2, 3);
                                    book(w .* height + h, index4, 4) = cache(w .* height + h, index2, 4);
                                    book(w .* height + h, index4, 5) = cache(w .* height + h, index2, 5);
                                    book(w .* height + h, index4, 6) = cache(w .* height + h, index2, 6);
                                    book(w .* height + h, index4, 7) = cache(w .* height + h, index2, 7);
                                    book(w .* height + h, index4, 8) = cache(w .* height + h, index2, 8);
                                    cache(w .* height + h, index2, 1) = -1;
                                    flag = 2;
                                    temp (w, h) = 200;
                                    break;
                                end
                            end
                            for index4 = 1: 6
                                if (book(w .* height + h, index4, 4) == leastfreq && flag ~= 2)
                                    book(w .* height + h, index4, 1) = cache(w .* height + h, index2, 1);
                                    book(w .* height + h, index4, 2) = cache(w .* height + h, index2, 2);
                                    book(w .* height + h, index4, 3) = cache(w .* height + h, index2, 3);
                                    book(w .* height + h, index4, 4) = cache(w .* height + h, index2, 4);
                                    book(w .* height + h, index4, 5) = cache(w .* height + h, index2, 5);
                                    book(w .* height + h, index4, 6) = cache(w .* height + h, index2, 6);
                                    book(w .* height + h, index4, 7) = cache(w .* height + h, index2, 7);
                                    book(w .* height + h, index4, 8) = cache(w .* height + h, index2, 8);
                                    cache(w .* height + h, index2, 1) = -1;
                                    flag = 2;
                                    temp (w, h) = 200;
                                    break;
                                end
                            end 
                            temp (w, h) = 200;
                        end

                        %find alpha and beta
                        if (curr >  cache(w .* height + h, index2, 1))
                            thisdif = curr -  cache(w .* height + h, index2, 1);
                            forvar = double(double(thisdif)/(double( varpos )));
                            
                        else
                            thisdif =  cache(w .* height + h, index2, 1) - curr;
                            forvar = double(double(thisdif)/(double( varneg)));
                            
                        end
                        alpha2 = double(forvar);
                        beta2 = max(1, double(2 - forvar));

                        %check if pixel matches cache entry, if so update
                        if (cache(w .* height + h, index2, 1) ~= -1 && curr >= (alpha2 .*  cache(w .* height + h, index2, 2)) && curr <= (min(cache(w .* height + h, index2, 3)./alpha2,  min(cache(w .* height + h, index2, 2) .*beta2))))
                            cache(w .* height + h, index2, 1) = double(double(cache(w .* height + h, index2, 1) .* double(cache(w .* height + h, index2, 4))) + double(curr))./double(double(cache(w .* height + h, index2, 4)) + double(1)) ;
                            cache(w .* height + h, index2, 2) = max(curr ,  cache(w .* height + h, index2, 2));
                            cache(w .* height + h, index2, 3) = min(curr, cache(w .* height + h, index2, 3) ) ;
                            cache(w .* height + h, index2, 8) = double(double(cache(w .* height + h, index2, 8) .* double(cache(w .* height + h, index2, 4))) + double(mvmnt))./double(double(cache(w .* height + h, index2, 4)) + double(1));
                            cache(w .* height + h, index2, 4) = double (cache(w .* height + h, index2, 4) + double(1));
                           
                            cache(w .* height + h, index2, 7) = double(l);
                            foundcache = 1;
                        elseif ( cache(w .* height + h, index2, 1) ~= -1)
                            cache(w .* height + h, index2, 5) = max(cache(w .* height + h, index2, 5), double(l)) - double(cache(w .* height + h, index2, 7));
                        end

                        %add to cache if not found
                        if (foundcache == 0)
                            for index3 = 1: 6
                                if (cache(w .* height + h, index3, 1) == -1)
                                    cache(w .* height + h, index3, 1) = curr;
                                    cache(w .* height + h, index3, 2) = curr;
                                    cache(w .* height + h, index3, 3) = curr;
                                    cache(w .* height + h, index3, 4) = 1;
                                    cache(w .* height + h, index3, 5) = 0;
                                    cache(w .* height + h, index3, 6) = l;
                                    cache(w .* height + h, index3, 7) = double(l);
                                    cache(w .* height + h, index3, 8) = mvmnt;
                                    break;
                                end
                            end
                        end
                    end
                    
                end
                last(w .* height + h, 4) = tempcurr; 
            end
        end

        %prep for next frame
        lastavg = double(double(double(lastavg) * double(double(l) - double(1)) + double(double(avg)./ double(pixels))) / double(l));
        varpos = double(double(double(double(varpos) * (double(double(l) - double(1))) + (double(double(difpos))./ double(poscount)))) / double(l));
        avgmvmnt = double(double(double(double(avgmvmnt) * (double(double(l) - double(1))) + (double(double(totalmvmnt))./ double(max(1, mvmntcount))))) / double(l));
        varneg = double(double(double(double(varneg) * (double(double(l) - double(1))) + (double(double(difneg))./ double(negcount)))) / double(l));
        dif = 0;
        avg = 0;
        difpos = 0;
        difneg = 0;
        poscount = 0;
        negcount = 0;
        disp(l);
        imshow(temp, []);
        writeVideo(finalvid, temp);
    end
    
    close(finalvid);