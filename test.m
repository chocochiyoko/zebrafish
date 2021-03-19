function test
  vidobj = VideoReader('316small.avi');
  frames = read(vidobj);
  gt = imread('zebrafish1000.png'); 
  gt = im2gray(gt);
  bothbgok = 0; 
  bothfgok = 0; 
  falsepositive = 0; 
  falsenegative = 0; 
  gtfg = 0; 
  gtbg = 0;
  pixels = 0;
  finalfalsepositive = double(99999); 
  finalfalsenegative = double(99999); 
  frame = 0; 
  disp("falsepositive")
  disp(finalfalsepositive)
  disp("falsenegative")
  disp(finalfalsenegative)
  for l = 800:1200
       mine = frames(:,:,:,l);
       mine = rgb2gray(mine);
       falsepositive = 0; 
       falsenegative = 0;
       gtfg = 0; 
        gtbg = 0;
        pixels = 0; 
      for w = 1:size(mine,1)
          for h = 1:size( mine,2)
             if(mine(w, h) < 128 && gt(w, h) < 128) 
                 bothfgok = double(bothfgok) + double(1); 
             end 
             if(mine(w, h) > 128 && gt(w, h) > 128) 
                 bothbgok = double(bothbgok) + double(1); 
             end 
             if(mine(w, h) < 128 && gt(w, h) > 128) 
                falsepositive = double(falsepositive) + double(1); 
             end 
             if(mine(w, h) > 128 && gt(w, h) < 128) 
                 falsenegative = double(falsenegative) + double(1); 
             end 
             if( gt(w, h) < 128) 
                 gtfg = double(gtfg) + double(1); 
             end 
             if(gt(w, h) > 128) 
                 gtbg = double(gtbg) + double(1); 
             end 
          end 
      end
       pixels = double(pixels) + double(1);
        finalfalsepositive = min(finalfalsepositive, falsepositive); 
        finalfalsenegative = min(finalfalsenegative, falsenegative);
        if(finalfalsepositive == falsepositive && finalfalsenegative == falsenegative)
            frame = l;
        end 
  end 
  imshow(frames(:,:,:,1001));
 
  disp("results")
  disp("falsepositive")
  disp(finalfalsepositive)
  disp("falsenegative")
  disp(finalfalsenegative)
  disp("frame")
  disp(frame)
  disp("percent error")
  disp((finalfalsepositive+finalfalsenegative)/(gtfg + gtbg) * 100)
  
end

