-- Listing 13.3
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity Pong_TopLevel is
   port(
      clk, reset, btn_l, btn_r, btn_u, btn_d: in std_logic;
      hsync, vsync: out  std_logic;
      red: out std_logic_vector(3 downto 0);
      green: out std_logic_vector(3 downto 0);
      blue: out std_logic_vector(3 downto 0)           
   );
end Pong_TopLevel;

architecture bouncing_box of Pong_TopLevel is
   signal pixel_x, pixel_y: std_logic_vector(9 downto 0);
   signal p1_pixel_x, p1_pixel_y: std_logic_vector(9 downto 0);
   signal p2_pixel_x, p2_pixel_y: std_logic_vector(9 downto 0);
   signal video_on, pixel_tick: std_logic;
   signal red_reg, red_next: std_logic_vector(3 downto 0) := (others => '0');
   signal green_reg, green_next: std_logic_vector(3 downto 0) := (others => '0');
   signal blue_reg, blue_next: std_logic_vector(3 downto 0) := (others => '0'); 
   signal dir_x, dir_y : integer := 1;  
   signal x, y, next_x, next_y : integer := 0;       
   signal box_xl, box_yt, box_xr, box_yb : integer := 0; 
   signal p1_xl, p1_yt, p1_xr, p1_yb : integer := 0;
   signal p2_xl, p2_yt, p2_xr, p2_yb : integer := 0;
   signal update_pos : std_logic := '0';  
   signal p1_x, p1_y, p1_next_y : integer := 0;  
   signal p2_x, p2_y, p2_next_y : integer := 0;  
begin
   -- instantiate VGA sync circuit
   vga_sync_unit: entity work.vga_sync
    port map(clk=>clk, reset=>reset, hsync=>hsync,
               vsync=>vsync, video_on=>video_on,
               pixel_x=>pixel_x, pixel_y=>pixel_y,
               p_tick=>pixel_tick);
               
    -- box position
    box_xl <= x;  
    box_yt <= y;
    box_xr <= x + 15;
    box_yb <= y + 15;  
    p1_xl <= p1_x;
    p1_yt <= p1_y;
    p1_xr <= p1_x + 5;
    p1_yb <= p1_y +20;
    p2_xl <= p2_x;
    p2_yt <= p2_y;
    p2_xr <= p2_x + 5;
    p2_yb <= p2_y +20;
    
    
    -- process to generate update position signal
    process ( video_on )
        variable counter : integer := 0;
    begin
        if rising_edge(video_on) then
            counter := counter + 1;
            if counter > 180 then
                counter := 0;
                update_pos <= '1';
            else
                update_pos <= '0';
            end if;
         end if;
    end process;

	
	-- compute collision in x
	process ( btn_r, btn_l, dir_x, clk, box_xr, box_xl, box_yt, box_yb)
	begin
        if rising_edge(clk) then 
		    if (box_xr > 639) and (dir_x = 1) then
                dir_x <= -1;
				x <=624;				
            elsif (box_xl < 1) and (dir_x = -1) then
                dir_x <= 1;   
				x <= 0;				
            elsif ( btn_r = '1' ) then 
                dir_x <= 1;
				x <= next_x;
            elsif ( btn_l = '1' ) then 
                dir_x <= -1;
				x <= next_x;
		    else 
				dir_x <= dir_x;
				x <= next_x;
            end if;
		end if;
	end process;
	
	-- compute collision in y
	process ( btn_u, btn_d, dir_y, clk, box_xr, box_xl, box_yt, box_yb)
	begin
        if rising_edge(clk) then 
		    if (box_yb > 479) and (dir_y = 1) then
                dir_y <= -1;
                y <=464 ;
            elsif (box_yt < 1) and (dir_y = -1) then
                dir_y <= 1;   
                y <= 0; 	
            elsif ( btn_u = '1' ) then 
                dir_y <= -1;
				y <= next_y;
            elsif ( btn_d = '1' ) then 
                dir_y <= 1;
				y <= next_y;
		    else 
				dir_y <= dir_y;
				y <= next_y;
            end if;
		end if;
	end process;	
	
    -- compute the next x,y position of box 
    process ( update_pos, x, y )
    begin
        if rising_edge(update_pos) then 
			next_x <= x + dir_x;
			next_y <= y + dir_y;
		end if;
    end process;
    
    -- process to generate next colors           
    process (pixel_x, pixel_y,p1_pixel_x, p1_pixel_y,p2_pixel_x, p2_pixel_y)
    begin
           if (unsigned(pixel_x) > box_xl) and (unsigned(pixel_x) < box_xr) and
           (unsigned(pixel_y) > box_yt) and (unsigned(pixel_y) < box_yb) and 
           (unsigned(p1_pixel_x) > p1_xl) and (unsigned(p1_pixel_x) < p1_xr) and
           (unsigned(p1_pixel_y) > p1_yt) and (unsigned(p1_pixel_y) < p1_yb) and 
           (unsigned(p2_pixel_x) > p2_xl) and (unsigned(p2_pixel_x) < p2_xr) and
           (unsigned(p2_pixel_y) > p2_yt) and (unsigned(p2_pixel_y) < p2_yb)
           then
               -- foreground box color yellow
               red_next <= "1111";
               green_next <= "0000";
               blue_next <= "0000"; 
           else    
               -- background color blue
               red_next <= "0000";
               green_next <= "0000";
               blue_next <= "0000";
           end if;   
    end process;

   -- generate r,g,b registers
   process ( video_on, pixel_tick, red_next, green_next, blue_next)
   begin
      if rising_edge(pixel_tick) then
          if (video_on = '1') then
            red_reg <= red_next;
            green_reg <= green_next;
            blue_reg <= blue_next;   
          else
            red_reg <= "0000";
            green_reg <= "0000";
            blue_reg <= "0000";                    
          end if;
      end if;
   end process;
   
   red <= STD_LOGIC_VECTOR(red_reg);
   green <= STD_LOGIC_VECTOR(green_reg); 
   blue <= STD_LOGIC_VECTOR(blue_reg);
     
end bouncing_box;