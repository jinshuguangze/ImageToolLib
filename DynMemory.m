<<<<<<< HEAD
classdef(Sealed) DynMemory%ä¸å…è®¸ç»§æ‰¿
%DynMemory:ä¸€ä¸ªåŠ¨æ€å†…å­˜ç±»ï¼Œå®žä¾‹åŒ–å‡ºæ¥çš„æ•°æ®ç±»åž‹èƒ½åœ¨å¾ªçŽ¯ä¸­è‡ªåŠ¨æ£€æµ‹æ˜¯å¦å·²æ»¡ï¼Œ
%                  å¹¶è‡ªåŠ¨ç”³è¯·æ–°çš„åˆé€‚çš„å†…å­˜ï¼Œä¹Ÿæä¾›ä¾¿åˆ©çš„å­—æ®µä¸Žå‡½æ•°ä»¥ä¾›æ‰‹åŠ¨æ£€æµ‹å¯¹è±¡å†…å­˜æ˜¯å¦è¶³å¤Ÿ
%TODO:
%1.äº†è§£äº‹ä»¶ç±»åž‹ï¼ˆeventï¼‰ï¼Œä½¿ç”¨ç›‘å¬å™¨æ¨¡åž‹æ¥æ›¿ä»£æ‰‹åŠ¨å¤–éƒ¨å¾ªçŽ¯ï¼Œå…¨ç›‘å¬å™¨ï¼Œå’Œéƒ¨åˆ†ç›‘å¬å™¨ä¸¤ç§æ¨¡åž‹
%å…¨ç›‘å¬å™¨åŒ…å«ä¸€ä¸ªä½¿ç”¨çŽ‡æ¨¡åž‹ï¼Œæ¯å½“åŽŸå¤§å°å’Œç»´åº¦ä¸­çš„0è¢«å¡«å……åˆ°åˆ«çš„å€¼æ—¶ï¼Œå¢žåŠ ä½¿ç”¨çŽ‡æ¯”ä¾‹ï¼Œåœ¨ä½¿ç”¨çŽ‡å¢žåŠ åˆ°
%Paraæ—¶ï¼Œä¼šè‡ªåŠ¨addMemoryï¼Œä½†æ˜¯å ç”¨å†…å­˜æˆ–è®¸è¾ƒå¤šï¼›éƒ¨åˆ†ç›‘å¬å™¨åªä¼šç›‘å¬åœ¨Paraä¹‹å¤–çš„æ•°å€¼å˜åŒ–ï¼Œä¸€æ—¦æœ‰å˜åŒ–ï¼Œ
%ä¼šç«‹å³addMemoryï¼Œè¿™æ ·å¯èƒ½ä¸å¤ªå‡†ç¡®ï¼Œå› ä¸ºæœ‰å¯èƒ½åœ¨å¤–éƒ¨å¯¹å€¼æ˜¯ä»ŽåŽéƒ¨å¼€å§‹å¾ªçŽ¯çš„
%2.åšä¸€ä¸ªæžšä¸¾é”®å€¼å¯¹æ¥å­˜å‚¨typeä¸Žå®žé™…ç±»åž‹
%3.å¤§æ•´æ”¹ï¼Œå…¨éƒ¨é€‚ç”¨validateattribute & inputParserå®žçŽ°
    properties%å…¬å¼€å­—æ®µ
        Value%å­˜å‚¨æ•°å€¼
        %å¯¹è±¡çš„å€¼åŸŸå­˜å‚¨åœ¨æ­¤å­—æ®µä¸­ï¼Œ
        %å…¬å¼€åŽŸå› æ˜¯éœ€è¦å¤–éƒ¨è®¿é—®ï¼Œèµ‹å€¼
    end
    
    properties(SetAccess=private)%åŠç§å¯†å­—æ®µ
        OriginalSize%åŽŸå§‹ç”³è¯·å®¹é‡
        %åŠå…¬å¼€åŽŸå› æ˜¯éœ€è¦å†…éƒ¨èµ‹å€¼ï¼Œå¤–éƒ¨è®¿é—®
    end
    
    properties(GetAccess=private,SetAccess=private)%ç§å¯†å­—æ®µ
        Type%å¯¹è±¡ç±»åž‹
        %å°†åœ¨ä½¿ç”¨ä»»ä½•å…¬å¼€æ–¹æ³•æ—¶è‡ªåŠ¨æ›´æ–°ï¼Œ
        %ç§å¯†åŽŸå› æ˜¯å¯èƒ½ç”±äºŽæ²¡æœ‰è°ƒç”¨å¯¹è±¡çš„æ–¹æ³•ï¼Œ
        %è€Œç›´æŽ¥è®¿é—®å­—æ®µè€Œå¯¼è‡´ä¿¡æ¯é”™è¯¯
        %-1:æœªçŸ¥
        %0:æ•°ç»„
        %1:ç»“æž„ä½“æ•°ç»„
        %2:ç»†èƒžæ•°ç»„
    end
    
    properties(Constant)%å¸¸é‡å­—æ®µ
        Scale=0.9%é»˜è®¤é•¿åº¦æ¯”ä¾‹å€¼
        %å¸¸é‡åŽŸå› æ˜¯éœ€è¦å¤šä¸ªå¯¹è±¡å…±äº«å•ä¸ªå€¼ä¸”ä¸èƒ½æ›´æ”¹
    end
    
    
    methods%æž„é€ å‡½æ•°
        function dynObj = DynMemory(varargin)
        %DynMemory:ç”³è¯·ä¸€æ®µå†…å­˜ï¼Œå¹¶åœ¨å½“å†…å­˜ä¸å¤Ÿçš„æ—¶å€™è‡ªåŠ¨æ‰©å……
        %varargin:å¯å˜å‚æ•°ï¼Œå¯ä»¥è¾“å…¥ä¸€åˆ°ä¸‰ä¸ªå‚æ•°ï¼Œå®Œæ•´ç‰ˆæœ¬çš„å‚æ•°åˆ†å¸ƒæ˜¯â€œè¡Œæ•°ï¼Œåˆ—æ•°ï¼Œæ•°æ®ç±»åž‹â€
        %dynObj:è¿”å›žä¸€ä¸ªå·²ç»åˆ†é…å¥½å†…å­˜çš„åŠ¨æ€å†…å­˜å¯¹è±¡ï¼Œé‡Œé¢å¤šä½™çš„ç©ºé—´ä¼šè¢«0å¡«å……
        %versin:1.0.2
        %author:jinshuguangze
        %data:4/15/2018
        %TODO:
        %1.é¦–å…ˆè¯»å–matlabè¯­è¨€ä¿¡æ¯ï¼Œç„¶åŽæ ¹æ®è¯­è¨€è¯»å–system('systeminfo')è¯»å–ä¿¡æ¯å¾—åˆ°å†…å­˜
        %æœ€å¤§å€¼åŽï¼Œæ ¹æ®matlabé¢„è®¾é¡¹å¾—åˆ°RAMå æ¯”ï¼Œç„¶åŽç¡®å®šæ•°ç»„å¤§å°çš„æœ€å¤§å€¼ï¼Œé»˜è®¤ä¸ºæœ€å¤§å¤§å°ä¸º
        %intmax('uint16')ï¼Œé™¤äº†ç»“æž„ä½“æ•°ç»„ä»¥å¤–ï¼Œç»“æž„ä½“æ•°ç»„æœ€å¤§ä¸Šé™ä¸ºintmax('uint64')
		%2.å¢žåŠ tall,tableç­‰ç±»åž‹

            switch nargin
                case 0%å½“è¾“å…¥å‚æ•°ä¸è¶³æ—¶ï¼Œå¼¹å‡ºè­¦å‘Šï¼Œåˆ›å»ºå¯¹è±¡å¤±è´¥
                    disp('åˆ›å»ºå¯¹è±¡å¤±è´¥ï¼Œè¯·è¾“å…¥è‡³å°‘ä¸€ä¸ªå‚æ•°ï¼');    
                    return;

                case 1%å½“è¾“å…¥å‚æ•°åªä¸ºä¸€ä¸ªæ—¶ï¼Œä¼šé»˜è®¤ç”Ÿæˆæ•°ç»„ï¼Œä¸”å‚æ•°åªå…è®¸å‡ºçŽ°æ­£æ•°  
                    if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0        
                        %æ­¤æ—¶åŠ¨æ€å†…å­˜å¯¹è±¡è¢«èµ‹äºˆä¸ºè¡Œå‘é‡ï¼Œä¸”æœ€é•¿é•¿åº¦ä¸ºintmax('uint16')
                        if varargin{1}>intmax('uint16')%è¾“å…¥å‚æ•°è¿‡å¤§
                            dynObj.Value=zeros(1,intmax('uint16'));%åˆ›å»ºå¯¹è±¡						
                            disp(['å‚æ•°1ï¼šåˆ—æ•°è¿‡å¤§ï¼Œè¶…è¿‡äº†',num2str(intmax('uint16')),...
								'ï¼Œé»˜è®¤ç”Ÿæˆå¤§å°ä¸º1x',num2str(intmax('uint16'),'çš„æ•°ç»„ã€‚')]);             
                        else%è¾“å…¥å‚æ•°åœ¨èŒƒå›´å†…
                            dynObj.Value=zeros(1,uint16(varargin{1}));%åˆ›å»ºå¯¹è±¡
                        end
                    else%å¦‚æžœè¾“å…¥çš„æ•°å­—ä¸ä¸ºæ­£æ•°
                        disp('åˆ›å»ºå¯¹è±¡å¤±è´¥ï¼Œå‚æ•°1ï¼šåˆ—æ•°å¿…é¡»ä¸ºä¸€ä¸ªæ­£æ•°ï¼');
                        return;
                    end
					dynObj.Type=0;%å­˜å‚¨ç±»åž‹åˆ°å­—æ®µï¼Œç±»åž‹ï¼šæ•°ç»„

                case 2%å½“è¾“å…¥å‚æ•°ä¸ºä¸¤ä¸ªæ—¶ï¼Œå…è®¸å‡ºçŽ°ä¸¤ä¸ªæ­£æ•°æˆ–è€…æ­£æ•°åŠ å­—ç¬¦ä¸²
                    if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0
                        if isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0%æ•°å­—åŠ æ•°å­—
                            %æ­¤æ—¶åŠ¨æ€å†…å­˜å¯¹è±¡è¢«èµ‹äºˆä¸ºæ•°ç»„ï¼Œä¸”ç”³è¯·å¤§å°ä¸è¶…è¿‡intmax('uint16')
                            if varargin{1}*varargin{2}>intmax('uint16')%è¾“å…¥å‚æ•°è¿‡å¤§
                                dynObj.Value=zeros(intmax('uint8'),intmax('uint8'));%åˆ›å»ºå¯¹è±¡
								disp(['å‚æ•°1ï¼šè¡Œæ•°ä¸Žå‚æ•°2ï¼šåˆ—æ•°çš„ä¹˜ç§¯è¿‡å¤§ï¼Œè¶…è¿‡äº†',...
									num2str(intmax('uint16')),'ï¼Œé»˜è®¤ç”Ÿæˆå¤§å°ä¸º',...
									num2str(intmax('uint8')),'x',num2str(intmax('uint8')),'çš„æ•°ç»„ã€‚']);
                            else%è¾“å…¥å‚æ•°åœ¨èŒƒå›´å†…                 
                                dynObj.Value=zeros(uint16(varargin{1}),uint16(varargin{2}));%åˆ›å»ºå¯¹è±¡
                            end
							dynObj.Type=0;%å­˜å‚¨ç±»åž‹åˆ°å­—æ®µï¼Œç±»åž‹ï¼šæ•°ç»„
                        elseif ischar(varargin{2})%æ•°å­—åŠ å­—ç¬¦ä¸²
                            switch varargin{2}
                                case 'array'%æ­¤æ—¶åŠ¨æ€å†…å­˜å¯¹è±¡è¢«èµ‹äºˆä¸ºè¡Œå‘é‡ï¼Œä¸”æœ€é•¿é•¿åº¦ä¸ºintmax('uint16')
                                    if varargin{1}>intmax('uint16')%è¾“å…¥å‚æ•°è¿‡å¤§
                                        dynObj.Value=zeros(1,intmax('uint16'));%åˆ›å»ºå¯¹è±¡
										disp(['å‚æ•°1ï¼šåˆ—æ•°è¿‡å¤§ï¼Œè¶…è¿‡äº†',num2str(intmax('uint16')),...
											'ï¼Œé»˜è®¤ç”Ÿæˆå¤§å°ä¸º1x',num2str(intmax('uint16'),'çš„æ•°ç»„ã€‚')]);      
                                    else%è¾“å…¥å‚æ•°åœ¨èŒƒå›´å†…
                                        dynObj.Value=zeros(1,uint16(varargin{1}));%åˆ›å»ºå¯¹è±¡
                                    end
									dynObj.Type=0;%å­˜å‚¨ç±»åž‹åˆ°å­—æ®µï¼Œç±»åž‹ï¼šæ•°ç»„
									
                                case 'struct'%æ­¤æ—¶åŠ¨æ€å†…å­˜å¯¹è±¡è¢«èµ‹äºˆä¸ºç»“æž„ä½“è¡Œå‘é‡ï¼Œæœ€é•¿é•¿åº¦ä¸ºintmax('uint64')
                                    if varargin{1}>intmax('uint64')%è¾“å…¥å‚æ•°è¿‡å¤§
                                        dynObj.Value(1,intmax('uint64'))=struct;%åˆ›å»ºå¯¹è±¡,å¤šç»´åº¦æ”¯æŒåŽå°è¯•ç”¨repmat
										disp(['å‚æ•°1ï¼šåˆ—æ•°è¿‡å¤§ï¼Œè¶…è¿‡äº†',num2str(intmax('uint64')),...
											'ï¼Œé»˜è®¤ç”Ÿæˆå¤§å°ä¸º1x',num2str(intmax('uint64'),'çš„ç»“æž„ä½“æ•°ç»„ã€‚')]);    
                                    else%è¾“å…¥å‚æ•°åœ¨èŒƒå›´å†…
                                        dynObj.Value(1,uint64(varargin{1}))=struct;%åˆ›å»ºå¯¹è±¡
                                    end
									dynObj.Type=1;%å­˜å‚¨ç±»åž‹åˆ°å­—æ®µï¼Œç±»åž‹ï¼šç»“æž„ä½“æ•°ç»„

                                case 'cell'%æ­¤æ—¶åŠ¨æ€å†…å­˜å¯¹è±¡è¢«èµ‹äºˆä¸ºç»†èƒžè¡Œå‘é‡ï¼Œä¸”æœ€é•¿é•¿åº¦ä¸ºintmax('uint16')
                                    if varargin{1}>intmax('uint16')%è¾“å…¥å‚æ•°è¿‡å¤§
                                        dynObj.Value=cell(1,intmax('uint16'));%åˆ›å»ºå¯¹è±¡
										disp(['å‚æ•°1ï¼šåˆ—æ•°è¿‡å¤§ï¼Œè¶…è¿‡äº†',num2str(intmax('uint16')),...
											'ï¼Œé»˜è®¤ç”Ÿæˆå¤§å°ä¸º1x',num2str(intmax('uint16'),'çš„ç»†èƒžæ•°ç»„ã€‚')]); 
                                    else%è¾“å…¥å‚æ•°åœ¨èŒƒå›´å†…
                                        dynObj.Value=cell(1,varargin{1});%åˆ›å»ºå¯¹è±¡
                                    end
									dynObj.Type=2;%å­˜å‚¨ç±»åž‹åˆ°å­—æ®µï¼Œç±»åž‹ï¼šç»†èƒžæ•°ç»„
									
                                otherwise%å­—ç¬¦ä¸²ä¸æ˜¯ä»¥ä¸Šä¸‰ç§
                                    dynObj.Value=zeros(1,intmax('uint16'));%åˆ›å»ºå¯¹è±¡
                                    disp(['ç›®å‰åªæ”¯æŒ''array''ï¼Œ''struct''ï¼Œ''cell''ä¸‰ç§ç±»åž‹çš„åŠ¨æ€å†…å­˜ç”³è¯·',...
                                        'ï¼Œé»˜è®¤ç”Ÿæˆå¤§å°ä¸º1x',num2str(intmax('uint16'),'çš„æ•°ç»„ã€‚')]); 
									dynObj.Type=0;%å­˜å‚¨ç±»åž‹åˆ°å­—æ®µï¼Œç±»åž‹ï¼šæ•°ç»„	
                            end
                        else%ç¬¬äºŒä¸ªå‚æ•°ä¸æ»¡è¶³æ¡ä»¶
                            disp('åˆ›å»ºå¯¹è±¡å¤±è´¥ï¼Œå‚æ•°2ï¼šåˆ—æ•°ï¼ˆæ•°æ®ç±»åž‹ï¼‰å¿…é¡»ä¸ºä¸€ä¸ªæ­£æ•°ï¼ˆå­—ç¬¦ä¸²ï¼‰ï¼');
                            return;
                        end
                    else%ç¬¬ä¸€ä¸ªå‚æ•°ä¸æ»¡è¶³æ¡ä»¶
                        disp('åˆ›å»ºå¯¹è±¡å¤±è´¥ï¼Œå‚æ•°1ï¼šåˆ—æ•°å¿…é¡»ä¸ºä¸€ä¸ªæ­£æ•°ï¼');
                        return;
                    end

                case 3%å½“è¾“å…¥å‚æ•°ä¸ºä¸‰ä¸ªæ—¶ï¼Œé¡ºåºå¿…é¡»æ˜¯æ•°å­—ï¼Œæ•°å­—ï¼Œå­—ç¬¦ä¸²
                    if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0 ...
                            && isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0 ...
                            && ischar(varargin{3})%æ»¡è¶³æ­£æ•°æ­£æ•°å­—ç¬¦ä¸²ç»„åˆ
                        switch varargin{3}
                            case 'array'%æ­¤æ—¶åŠ¨æ€å†…å­˜å¯¹è±¡è¢«èµ‹äºˆä¸ºæ•°ç»„ï¼Œä¸”ç”³è¯·å¤§å°ä¸è¶…è¿‡intmax('uint16')
                                if varargin{1}*varargin{2}>intmax('uint16')%è¾“å…¥å‚æ•°è¿‡å¤§
                                    dynObj.Value=zeros(intmax('uint8'),intmax('uint8'));%åˆ›å»ºå¯¹è±¡
									disp(['å‚æ•°1ï¼šè¡Œæ•°ä¸Žå‚æ•°2ï¼šåˆ—æ•°çš„ä¹˜ç§¯è¿‡å¤§ï¼Œè¶…è¿‡äº†',...
										num2str(intmax('uint16')),'ï¼Œé»˜è®¤ç”Ÿæˆå¤§å°ä¸º',...
										num2str(intmax('uint8')),'x',num2str(intmax('uint8')),'çš„æ•°ç»„ã€‚']);
                                else%è¾“å…¥å‚æ•°åœ¨èŒƒå›´å†…                 
                                    dynObj.Value=zeros(uint16(varargin{1}),uint16(varargin{2}));%åˆ›å»ºå¯¹è±¡
                                end
								dynObj.Type=0;%å­˜å‚¨ç±»åž‹åˆ°å­—æ®µï¼Œç±»åž‹ï¼šæ•°ç»„

                            case 'struct'%æ­¤æ—¶åŠ¨æ€å†…å­˜å¯¹è±¡è¢«èµ‹äºˆä¸ºç»“æž„ä½“æ•°ç»„ï¼Œè¡Œæ•°ä¸Žåˆ—æ•°éƒ½ä¸è¶…è¿‡intmax('uint64')
                                if varargin{1}>intmax('uint64') && varargin{2}<=intmax('uint64')%å‚æ•°1è¿‡å¤§
                                    dynObj.Value(intmax('uint64'),uint64(varargin{2}))=struct;%åˆ›å»ºå¯¹è±¡
                                    disp(['å‚æ•°1ï¼šè¡Œæ•°è¿‡å¤§ï¼Œè¶…è¿‡äº†',num2str(intmax('uint64')),...
										'ï¼Œé»˜è®¤ç”Ÿæˆå¤§å°ä¸º',num2str(intmax('uint64')),'x',...
										num2str(uint64(varargin{2})),'çš„ç»“æž„ä½“æ•°ç»„ã€‚']);
                                elseif varargin{1}<=intmax('uint64') && varargin{2}>intmax('uint64')%å‚æ•°2è¿‡å¤§
                                    dynObj.Value(uint64(varargin{1}),intmax('uint64'))=struct;%åˆ›å»ºå¯¹è±¡
                                    disp(['å‚æ•°2ï¼šåˆ—æ•°è¿‡å¤§ï¼Œè¶…è¿‡äº†',num2str(intmax('uint64')),...
										'ï¼Œé»˜è®¤ç”Ÿæˆå¤§å°ä¸º',num2str(uint64(varargin{1})),'x',...
										num2str(intmax('uint64')),'çš„ç»“æž„ä½“æ•°ç»„ã€‚']);
								elseif	varargin{1}>intmax('uint64') && varargin{2}>intmax('uint64')%å‚æ•°1,2éƒ½è¿‡å¤§
                                    dynObj.Value(intmax('uint64'),intmax('uint64'))=struct;%åˆ›å»ºå¯¹è±¡
                                    disp(['å‚æ•°1ï¼šè¡Œæ•°å’Œå‚æ•°2ï¼šåˆ—æ•°éƒ½è¿‡å¤§ï¼Œéƒ½è¶…è¿‡äº†',num2str(intmax('uint64')),...
										'ï¼Œé»˜è®¤ç”Ÿæˆå¤§å°ä¸º',num2str(uint64(varargin{1})),'x',...
										num2str(intmax('uint64')),'çš„ç»“æž„ä½“æ•°ç»„ã€‚']);																								
                                else%è¾“å…¥å‚æ•°åœ¨èŒƒå›´å†…
                                    dynObj.Value(uint64(varargin{1}),uint64(varargin{2}))=struct;%åˆ›å»ºå¯¹è±¡
                                end
								dynObj.Type=1;%å­˜å‚¨ç±»åž‹åˆ°å­—æ®µï¼Œç±»åž‹ï¼šç»“æž„ä½“æ•°ç»„
								
                            case 'cell'%æ­¤æ—¶åŠ¨æ€å†…å­˜å¯¹è±¡è¢«èµ‹äºˆä¸ºç»†èƒžæ•°ç»„ï¼Œä¸”ç”³è¯·å¤§å°ä¸è¶…è¿‡intmax('uint16')
                                if varargin{1}*varargin{2}>intmax('uint16')%è¾“å…¥å‚æ•°è¿‡å¤§
                                    dynObj.Value=cell(intmax('uint8'),intmax('uint8'));%åˆ›å»ºå¯¹è±¡
									disp(['å‚æ•°1ï¼šè¡Œæ•°ä¸Žå‚æ•°2ï¼šåˆ—æ•°çš„ä¹˜ç§¯è¿‡å¤§ï¼Œè¶…è¿‡äº†',...
										num2str(intmax('uint16')),'ï¼Œé»˜è®¤ç”Ÿæˆå¤§å°ä¸º',...
										num2str(intmax('uint8')),'x',num2str(intmax('uint8')),'çš„ç»†èƒžæ•°ç»„ã€‚']);
                                else%è¾“å…¥å‚æ•°åœ¨èŒƒå›´å†…                 
                                    dynObj.Value=cell(uint16(varargin{1}),uint16(varargin{2}));%åˆ›å»ºå¯¹è±¡
                                end
								dynObj.Type=2;%å­˜å‚¨ç±»åž‹åˆ°å­—æ®µï¼Œç±»åž‹ï¼šç»†èƒžæ•°ç»„

                            otherwise%å­—ç¬¦ä¸²ä¸æ˜¯ä»¥ä¸Šä¸‰ç§
                                dynObj.Value=zeros(intmax('uint8'),intmax('uint8'));%åˆ›å»ºå¯¹è±¡
								disp(['ç›®å‰åªæ”¯æŒ''array''ï¼Œ''struct''ï¼Œ''cell''ä¸‰ç§ç±»åž‹çš„åŠ¨æ€å†…å­˜ç”³è¯·',...
									'ï¼Œé»˜è®¤ç”Ÿæˆå¤§å°ä¸º',num2str(intmax('uint8'),'x',...
									num2str(intmax('uint8')),'çš„æ•°ç»„ã€‚')]); 
								dynObj.Type=0;%å­˜å‚¨ç±»åž‹åˆ°å­—æ®µï¼Œç±»åž‹ï¼šæ•°ç»„	
                        end
                    else%å‚æ•°æŽ’åˆ—ç»„åˆä¸æ»¡è¶³æ¡ä»¶
                        disp(['åˆ›å»ºå¯¹è±¡å¤±è´¥ï¼Œ'...
							'å‚æ•°1ï¼šåˆ—æ•°å¿…é¡»ä¸ºä¸€ä¸ªæ­£æ•°ï¼Œ',...
                            'å‚æ•°2ï¼šè¡Œæ•°å¿…é¡»ä¸ºä¸€ä¸ªæ­£æ•°ï¼Œ',...
                            'å‚æ•°3ï¼šæ•°æ®ç±»åž‹å¿…é¡»ä¸ºä¸€ä¸ªå­—ç¬¦ä¸²ï¼']);
                        return;
                    end

                otherwise%å½“è¾“å…¥å‚æ•°è¿‡å¤šæ—¶
                    disp('åˆ›å»ºå¯¹è±¡å¤±è´¥ï¼Œè¾“å…¥å‚æ•°è¿‡å¤šï¼');
                    return;
            end
			dynObj.OriginalSize=size(dynObj.Value);%ä¿å­˜åŽŸå§‹å¤§å°åˆ°å­—æ®µ
        end	
    end
    
	
    methods%å…¬å¼€å‡½æ•°
        function dynObj=refresh(dynObj,varargin)
        %refresh:è®¿é—®å¯¹è±¡å†…å†…å­˜æœ«ç«¯æœ€åŽä¸€ç³»åˆ—æ•°å­—æ˜¯å¦ä¸º0ï¼Œå¦‚æžœæœ‰æ•°å­—æ›´æ”¹è¿‡ï¼Œ
		%		    åˆ™ç”³è¯·æ›´å¤§çš„å†…å­˜æœ‰å¯èƒ½ä¼šå› ä¸ºæœ¬èº«æ•°ç»„æœ€åŽä¸€ç³»åˆ—æ•°å­—ä¸º0è€Œåˆ·æ–°å¤±è´¥ï¼Œ
		%		    ä¼šå› æ­¤è€Œæš‚æ—¶é™ä½Žæ•ˆçŽ‡ï¼Œä¸€æ—¦æœ‰éž0æ•°å­—è¾“å…¥ï¼Œä¼šé©¬ä¸Šæé«˜æ•ˆçŽ‡
		%dynObj:è¢«å¤„ç†çš„åŠ¨æ€å†…å­˜å¯¹è±¡ï¼Œå¯èƒ½æœ‰é•¿åº¦çš„æ‰©å®¹
		%varargin:å¯é€‰çš„è¾“å…¥ï¼Œå¯ä»¥è®¾ç½®å¾ªçŽ¯æ£€æµ‹çš„é•¿åº¦æ¯”ä¾‹æˆ–è€…æ£€æµ‹å›ºå®šé•¿åº¦ï¼Œ
		%			  å¦‚æžœç»å¯¹å€¼å°äºŽ1ï¼Œåˆ™æ˜¯æŒ‰ç…§é•¿åº¦æ¯”ä¾‹ï¼Œå¦åˆ™æ˜¯æŒ‰ç…§å›ºå®šé•¿åº¦
		%			  å¦‚æžœæ˜¯è´Ÿæ•°ï¼Œåˆ™ä»Žå¤´å¼€å§‹æ£€æµ‹è€Œä¸æ˜¯ä»Žå°¾éƒ¨å¼€å§‹æ£€æµ‹ï¼Œ
		%		      å¦‚æžœä¸è¾“å…¥ï¼Œåˆ™ä¼šä½¿ç”¨é»˜è®¤å€¼ï¼Œå¦‚æžœåªè¾“å…¥ä¸€ä¸ªå€¼ï¼Œé‚£ä¹ˆä¼šä¼˜å…ˆè®¾ç½®
		%			  è¡Œæ•°ï¼Œå¹¶å°è¯•å°†åˆ—æ•°å’Œè¡Œæ•°å‚æ•°å˜æˆä¸€è‡´ï¼Œå¦‚æžœå¤±è´¥ï¼Œåˆ™åˆ—æ•°ä¼šè®¾ç½®æˆé»˜è®¤å€¼
        %versin:1.0.2
        %author:jinshuguangze
        %data:4/17/2018	
			
			dynObj.checkType;%å¯¹å¯¹è±¡çš„å€¼åŸŸè¿›è¡Œç±»åž‹æ£€æŸ¥
			[row,col]=size(dynObj.Value);%èŽ·å–å¯¹è±¡è¡Œæ•°å’Œåˆ—æ•°
			
			p=inputParser;%æž„é€ å…¥å£æ£€éªŒå¯¹è±¡
			p.addOptional('rowScale',dynObj.Scale,@(x)validateattributes(x,{'numeric'},...
				{'scalar','nonzero','>',-row,'<',row},'refresh','rowScale',1));			
			p.addOptional('colScale',dynObj.Scale,@(x)validateattributes(x,{'numeric'},...
				{'scalar','nonzero','>',-col,'<',col},'refresh','colScale',2));

			p.parse(varargin{:});	
			rScale=p.Results.rowScale;%å¾—åˆ°å…¥å£æ£€éªŒåŽçš„å€¼
			cScale=p.Results.colScale;
			
			if nargin==2%å¦‚æžœåªè¾“å…¥ä¸€ä¸ªæ•°å€¼ï¼Œåˆ™åˆ—æ•°å‚æ•°å°è¯•ç­‰äºŽè¡Œæ•°å‚æ•°
				if rScale<col%å°è¯•æˆåŠŸ
					cScale=rScale;
				else%å°è¯•å¤±è´¥ï¼Œè®¾ç½®æˆé»˜è®¤å€¼
					cScale=dynObj.Scale;
				end
			end							
			
			if rScale>=1%æž„é€ åŸºäºŽè¡Œæ•°å‚æ•°çš„å¯¹è±¡å€¼åŸŸå¾ªçŽ¯å™¨
				rloop=row:-1:row-ceil(rScale);
			elseif rScale>0 && rScale<1
				rloop=row:-1:ceil(row*rScale);
			elseif rScale>-1 && rScale<0
				rloop=1:floor(-row*rScale);
			else
				rloop=1:floor(-rScale);
			end
			
			if cScale>=1%æž„é€ åŸºäºŽåˆ—æ•°å‚æ•°çš„å¯¹è±¡å€¼åŸŸå¾ªçŽ¯å™¨
				cloop=col:-1:col-ceil(cScale);
			elseif cScale>0 && cScale<1
				cloop=col:-1:ceil(col*cScale);
			elseif cScale>-1 && cScale<0
				cloop=1:floor(-col*cScale);
			else
				cloop=1:floor(-cScale);
			end
			
			switch dynObj.Type%å¯¹äºŽå¯¹è±¡çš„ä¸åŒç±»åž‹æœ‰ä¸åŒå¤„ç†
				case 0%æ•°ç»„
					if dynObj.Value(rloop,cloop)
						dynObj=dynObj.addMemory;
						return;
					end
				
				case 1%ç»“æž„ä½“æ•°ç»„
					fields=fieldnames(dynObj.Value);
					kloop=1:size(fields,1);%æž„é€ è®¿é—®æ‰€æœ‰å­—æ®µçš„å¾ªçŽ¯å™¨
					if size(fields,1)
						if ~isempty(getfield(dynObj.Value(rloop,cloop),fields{kloop,1}))%è®¿é—®æ¯ä¸ªå­—æ®µçš„å€¼æ˜¯å¦ä¸ºç©º
							dynObj=dynObj.addMemory;
							return;
						end
					end
					
				case 2%ç»†èƒžæ•°ç»„
					if ~isempty(dynObj.Value{rloop,cloop})
						dynObj=dynObj.addMemory;
						return;
					end	
			end
        end       
        
		
        function dynObj=addMemory(dynObj,varargin)
        %addMemory:ç”±äºŽå‡½æ•°æ˜¯å…¬å¼€çš„ï¼Œæ‰€ä»¥å¯ä»¥æ‰‹åŠ¨åŽ»ç”³è¯·æ›´å¤§çš„å†…å­˜ï¼Œ
		%                  é»˜è®¤ä¸ºå¢žåŠ è¡Œæ•°ï¼Œæ•°å€¼ä¸ºåˆå§‹ç”³è¯·å†…å­˜çš„è¡Œæ•°
        %dynObj:è¢«å¤„ç†çš„åŠ¨æ€å†…å­˜å¯¹è±¡ï¼Œé•¿åº¦å·²ç»å¢žåŠ 
		%varargin:å¯é€‰çš„è¾“å…¥ï¼Œå¯ä»¥æ ¹æ®è¾“å…¥æ¥è®¾ç½®å¢žåŠ å€¼çš„å¤§å°ï¼Œ
		%             æˆ–è€…é€‰æ‹©å¢žåŠ çš„æ–¹å‘æ˜¯è¡Œæˆ–è€…åˆ—ï¼Œæˆ–è€…éƒ½è®¾ç½®
        %versin:1.0.2
        %author:jinshuguangze
        %data:4/17/2018	
		%TODO:
		%1.å¤šç»´åº¦å¢žåŠ æ”¯æŒï¼ˆè€Œä¸æ˜¯ä¸¤ç»´åº¦ï¼‰ï¼š('D1',2,'D2',4,'D5',9,10<-è¿™ä¸ªé»˜è®¤ä¸ºå‰é¢ç¡®å®šç»´åº¦çš„åŽä¸€ç»´ï¼Œå³D6)	
		%2.å¦‚æžœå¯¹è±¡ç»´åº¦å’Œå¤§å°æ”¹å˜äº†ï¼Œcatå‡½æ•°ä¼šçµæ´»è°ƒæ•´ï¼Œå¦‚æžœæ˜¯dimæ–¹å‘ä¸Šçš„æ‹¼æŽ¥ï¼Œåˆ™å¿…é¡»ä¿è¯é™¤äº†dimï¼Œå…¶ä»–å¤§å°éƒ½è¦æ»¡è¶³	
		%	for i=1:nargin
		%		if ischar(varargin{i}) && ...å­—ç¬¦æ‹¼æŽ¥ç›¸å…³	
		
			dim=1;%æ–¹å‘é»˜è®¤ä¸ºè¡Œæ•°æ–¹å‘
			rowadd=dynObj.OriginalSize(1);%è¡Œæ•°é»˜è®¤å¢žåŠ orignalRow
			coladd=0;%åˆ—æ•°é»˜è®¤å¢žåŠ 0
			if nargin==1%å¦‚æžœæ— å‚æ•°è¾“å…¥ï¼Œç»“æžœä¸ºé»˜è®¤			
			elseif nargin==2%å¦‚æžœæœ‰ä¸€ä¸ªå‚æ•°è¾“å…¥ï¼Œæœ‰å¯èƒ½æ˜¯ä¸€ä¸ªå†³å®šå¢žåŠ æ–¹å‘çš„å­—ç¬¦ä¸²ï¼Œæˆ–è€…æ˜¯å†³å®šå¢žåŠ æ•°å€¼çš„æ­£æ•°
				if ischar(varargin{1})%æ»¡è¶³æ˜¯ä¸ªå­—ç¬¦ä¸²
					if varargin{1}=='col'
						dim=1;%æ–¹å‘æ”¹ä¸ºå¢žåŠ åˆ—æ•°
					else
						disp('å‚æ•°1ï¼šæ–¹å‘å¿…é¡»ä¸º''row''å’Œ''col''å…¶ä¸­ä¹‹ä¸€ï¼Œå·²è®¾ç½®æˆé»˜è®¤å€¼ï¼šç¬¬ä¸€ç»´åº¦ã€‚');
					end
				elseif isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0%æ»¡è¶³æ˜¯ä¸ªæ­£æ•°
					rowadd=uint16(varargin{1});%ä¿®æ”¹å¢žåŠ è¡Œæ•°
				else%å¦‚æžœä¸æ»¡è¶³æ¡ä»¶
					disp('å¢žåŠ å†…å­˜å¤±è´¥ï¼ŒåŽŸå› ï¼šå‚æ•°1ï¼šæ–¹å‘ï¼ˆå¢žåŠ è¡Œæ•°ï¼‰å¿…é¡»ä¸ºå­—ç¬¦ä¸²ï¼ˆæ­£æ•°ï¼‰ï¼');
					return;
				end
			elseif nargin==3%å¦‚æžœæœ‰ä¸¤ä¸ªå‚æ•°è¾“å…¥ï¼Œå¿…é¡»ä¸ºä¸¤ä¸ªæ­£æ•°
				if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0 ...
                    && isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0%ä¸¤ä¸ªæ­£æ•°
					rowadd=unit16(varargin{1});%è®¾ç½®è¡Œæ•°å¢žåŠ å€¼
					coladd=unit16(varargin{2});%è®¾ç½®åˆ—æ•°å¢žåŠ å€¼
				else
					disp('å¢žåŠ å†…å­˜å¤±è´¥ï¼ŒåŽŸå› ï¼šå‚æ•°1ï¼šå¢žåŠ è¡Œæ•°ä¸Žå‚æ•°2ï¼šå¢žåŠ åˆ—æ•°å¿…é¡»éƒ½ä¸ºæ­£æ•°ï¼');
					return;
				end	
			else%å‚æ•°è¾“å…¥è¿‡å¤š
				disp('å¢žåŠ å†…å­˜å¤±è´¥ï¼ŒåŽŸå› ï¼šè¾“å…¥å‚æ•°è¿‡å¤šï¼');
				return;
			end
			
            switch dynObj.Type%å¯¹äºŽå¯¹è±¡çš„ä¸åŒç±»åž‹æœ‰ä¸åŒå¤„ç†
				case 0%å¦‚æžœå¯¹è±¡æ˜¯æ•°ç»„
					newMemory=zeros(dynObj.OriginalSize);
					
				case 1%å¦‚æžœå¯¹è±¡æ˜¯ç»“æž„ä½“æ•°ç»„
					newMemory=repmat(struct,dynObj.OriginalSize);
					
				case 2%å¦‚æžœå¯¹è±¡æ˜¯ç»†èƒžæ•°ç»„
					newMemory=cell(dynObj.OriginalSize);
            end
			dynObj.Value=cat(dim,dynObj.Value,newMemory);%æ‹¼æŽ¥æ•°ç»„			
        end                    
    end
    
	methods(Access=private)%ç§å¯†æ–¹æ³•
		function type=checkType(dynObj)
		%checkType:é€‚ç”¨äºŽå†…éƒ¨å†åˆ¤æ–­å¯¹è±¡çš„ç±»åž‹ï¼Œä¼šè‡ªåŠ¨æ”¹å˜Typeå±žæ€§è‡³å½“å‰å¯¹è±¡ç±»åž‹
		%dynObj:è¢«æ£€æµ‹çš„åŠ¨æ€å†…å­˜å¯¹è±¡
		%type:è¿”å›žå½“å‰çš„ç±»åž‹
		%versin:1.0.0
        %author:jinshuguangze
		%data:4/19/2018	
		
			if ~ismatrix(dynObj.Value)%éžæ•°ç»„åˆ¤å®šä¸ºæœªçŸ¥ç±»åž‹
				type=-1;
				clear dynObj;
				disp('å¯¹è±¡ç±»åž‹é”™è¯¯ï¼Œå·²ç»è‡ªæˆ‘æ¸…é™¤ï¼');
				return;
			elseif isstruct(dynObj.Value)%ç»“æž„ä½“æ•°ç»„
				type=1;
			elseif iscell(dynObj.Value)%ç»†èƒžæ•°ç»„
				type=2;
			else%å…¶ä»–æ‰€æœ‰ç»Ÿç§°ä¸ºæ™®é€šæ•°ç»„
				type=0;
			end
		end
	end
		
    methods%set,getæ–¹æ³•é›†åˆ
        function value=get.Value(dynObj)
            value=dynObj.Value;
        end
        
        function dynObj=set.Value(dynObj,value)
            dynObj.Value=value;
        end
        
        function originalSize=get.OriginalSize(dynObj)
            originalSize=dynObj.OriginalSize;
        end
        
        function dynObj=set.OriginalSize(dynObj,originalSize)
            dynObj.OriginalSize=originalSize;
        end
        
        function type=get.Type(dynObj)
            type=dynObj.Type;
        end
        
        function dynObj=set.Type(dynObj,type)
            dynObj.Type=type;
        end     
    end
=======
classdef(Sealed) DynMemory%²»ÔÊÐí¼Ì³Ð
%DynMemory:Ò»¸ö¶¯Ì¬ÄÚ´æÀà£¬ÊµÀý»¯³öÀ´µÄÊý¾ÝÀàÐÍÄÜÔÚÑ­»·ÖÐ×Ô¶¯¼ì²âÊÇ·ñÒÑÂú£¬
%                  ²¢×Ô¶¯ÉêÇëÐÂµÄºÏÊÊµÄÄÚ´æ£¬Ò²Ìá¹©±ãÀûµÄ×Ö¶ÎÓëº¯ÊýÒÔ¹©ÊÖ¶¯¼ì²â¶ÔÏóÄÚ´æÊÇ·ñ×ã¹»
%TODO:
%1.ÁË½âÊÂ¼þÀàÐÍ£¨event£©£¬Ê¹ÓÃ¼àÌýÆ÷Ä£ÐÍÀ´Ìæ´úÊÖ¶¯Íâ²¿Ñ­»·£¬È«¼àÌýÆ÷£¬ºÍ²¿·Ö¼àÌýÆ÷Á½ÖÖÄ£ÐÍ
%È«¼àÌýÆ÷°üº¬Ò»¸öÊ¹ÓÃÂÊÄ£ÐÍ£¬Ã¿µ±Ô­´óÐ¡ºÍÎ¬¶ÈÖÐµÄ0±»Ìî³äµ½±ðµÄÖµÊ±£¬Ôö¼ÓÊ¹ÓÃÂÊ±ÈÀý£¬ÔÚÊ¹ÓÃÂÊÔö¼Óµ½
%ParaÊ±£¬»á×Ô¶¯addMemory£¬µ«ÊÇÕ¼ÓÃÄÚ´æ»òÐí½Ï¶à£»²¿·Ö¼àÌýÆ÷Ö»»á¼àÌýÔÚParaÖ®ÍâµÄÊýÖµ±ä»¯£¬Ò»µ©ÓÐ±ä»¯£¬
%»áÁ¢¼´addMemory£¬ÕâÑù¿ÉÄÜ²»Ì«×¼È·£¬ÒòÎªÓÐ¿ÉÄÜÔÚÍâ²¿¶ÔÖµÊÇ´Óºó²¿¿ªÊ¼Ñ­»·µÄ
%2.×öÒ»¸öÃ¶¾Ù¼üÖµ¶ÔÀ´´æ´¢typeÓëÊµ¼ÊÀàÐÍ
    properties%¹«¿ª×Ö¶Î
        Value%´æ´¢ÊýÖµ
        %¶ÔÏóµÄÖµÓò´æ´¢ÔÚ´Ë×Ö¶ÎÖÐ£¬
        %¹«¿ªÔ­ÒòÊÇÐèÒªÍâ²¿·ÃÎÊ£¬¸³Öµ
    end
    
    properties(SetAccess=private)%°ëË½ÃÜ×Ö¶Î
        OriginalSize%Ô­Ê¼ÉêÇëÈÝÁ¿
        %°ë¹«¿ªÔ­ÒòÊÇÐèÒªÄÚ²¿¸³Öµ£¬Íâ²¿·ÃÎÊ
    end
    
    properties(GetAccess=private,SetAccess=private)%Ë½ÃÜ×Ö¶Î
        Type%¶ÔÏóÀàÐÍ
        %½«ÔÚÊ¹ÓÃÈÎºÎ¹«¿ª·½·¨Ê±×Ô¶¯¸üÐÂ£¬
        %Ë½ÃÜÔ­ÒòÊÇ¿ÉÄÜÓÉÓÚÃ»ÓÐµ÷ÓÃ¶ÔÏóµÄ·½·¨£¬
        %¶øÖ±½Ó·ÃÎÊ×Ö¶Î¶øµ¼ÖÂÐÅÏ¢´íÎó
        %-1:Î´Öª
        %0:Êý×é
        %1:½á¹¹ÌåÊý×é
        %2:Ï¸°ûÊý×é
    end
    
    properties(Constant)%³£Á¿×Ö¶Î
        Scale=0.9%Ä¬ÈÏ³¤¶È±ÈÀýÖµ
        %³£Á¿Ô­ÒòÊÇÐèÒª¶à¸ö¶ÔÏó¹²Ïíµ¥¸öÖµÇÒ²»ÄÜ¸ü¸Ä
    end
    
    
    methods%¹¹Ôìº¯Êý
        function dynObj = DynMemory(varargin)
        %DynMemory:ÉêÇëÒ»¶ÎÄÚ´æ£¬²¢ÔÚµ±ÄÚ´æ²»¹»µÄÊ±ºò×Ô¶¯À©³ä
        %varargin:¿É±ä²ÎÊý£¬¿ÉÒÔÊäÈëÒ»µ½Èý¸ö²ÎÊý£¬ÍêÕû°æ±¾µÄ²ÎÊý·Ö²¼ÊÇ¡°ÐÐÊý£¬ÁÐÊý£¬Êý¾ÝÀàÐÍ¡±
        %dynObj:·µ»ØÒ»¸öÒÑ¾­·ÖÅäºÃÄÚ´æµÄ¶¯Ì¬ÄÚ´æ¶ÔÏó£¬ÀïÃæ¶àÓàµÄ¿Õ¼ä»á±»0Ìî³ä
        %versin:1.0.2
        %author:jinshuguangze
        %data:4/15/2018
        %TODO:
        %1.Ê×ÏÈ¶ÁÈ¡matlabÓïÑÔÐÅÏ¢£¬È»ºó¸ù¾ÝÓïÑÔ¶ÁÈ¡system('systeminfo')¶ÁÈ¡ÐÅÏ¢µÃµ½ÄÚ´æ
        %×î´óÖµºó£¬¸ù¾ÝmatlabÔ¤ÉèÏîµÃµ½RAMÕ¼±È£¬È»ºóÈ·¶¨Êý×é´óÐ¡µÄ×î´óÖµ£¬Ä¬ÈÏÎª×î´ó´óÐ¡Îª
        %intmax('uint16')£¬³ýÁË½á¹¹ÌåÊý×éÒÔÍâ£¬½á¹¹ÌåÊý×é×î´óÉÏÏÞÎªintmax('uint64')
        %2.Ôö¼ÓÒ»¸ö²ÎÊýÈ·¶¨Ô¤·ÖÅäµÄÊý¾ÝÀàÐÍ
		%3.ÐÞ¸Äº¯ÊýÒÔÊÊÓ¦¹¹Ôìº¯ÊýÀà£¬½«×Ö¶Î¸³Öµ
		%4.Ôö¼Ótall,tableµÈÀàÐÍ
		%5.Ôö¼Ó¶àÎ¬¶ÈÖ§³Ö

            switch nargin
                case 0%µ±ÊäÈë²ÎÊý²»×ãÊ±£¬µ¯³ö¾¯¸æ£¬´´½¨¶ÔÏóÊ§°Ü
                    disp('´´½¨¶ÔÏóÊ§°Ü£¬ÇëÊäÈëÖÁÉÙÒ»¸ö²ÎÊý£¡');    
                    return;

                case 1%µ±ÊäÈë²ÎÊýÖ»ÎªÒ»¸öÊ±£¬»áÄ¬ÈÏÉú³ÉÊý×é£¬ÇÒ²ÎÊýÖ»ÔÊÐí³öÏÖÕýÊý  
                    if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0        
                        %´ËÊ±¶¯Ì¬ÄÚ´æ¶ÔÏó±»¸³ÓèÎªÐÐÏòÁ¿£¬ÇÒ×î³¤³¤¶ÈÎªintmax('uint16')
                        if varargin{1}>intmax('uint16')%ÊäÈë²ÎÊý¹ý´ó
                            dynObj.Value=zeros(1,intmax('uint16'));%´´½¨¶ÔÏó						
                            disp(['²ÎÊý1£ºÁÐÊý¹ý´ó£¬³¬¹ýÁË',num2str(intmax('uint16')),...
								'£¬Ä¬ÈÏÉú³É´óÐ¡Îª1x',num2str(intmax('uint16'),'µÄÊý×é¡£')]);             
                        else%ÊäÈë²ÎÊýÔÚ·¶Î§ÄÚ
                            dynObj.Value=zeros(1,uint16(varargin{1}));%´´½¨¶ÔÏó
                        end
                    else%Èç¹ûÊäÈëµÄÊý×Ö²»ÎªÕýÊý
                        disp('´´½¨¶ÔÏóÊ§°Ü£¬²ÎÊý1£ºÁÐÊý±ØÐëÎªÒ»¸öÕýÊý£¡');
                        return;
                    end
					dynObj.Type=0;%´æ´¢ÀàÐÍµ½×Ö¶Î£¬ÀàÐÍ£ºÊý×é

                case 2%µ±ÊäÈë²ÎÊýÎªÁ½¸öÊ±£¬ÔÊÐí³öÏÖÁ½¸öÕýÊý»òÕßÕýÊý¼Ó×Ö·û´®
                    if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0
                        if isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0%Êý×Ö¼ÓÊý×Ö
                            %´ËÊ±¶¯Ì¬ÄÚ´æ¶ÔÏó±»¸³ÓèÎªÊý×é£¬ÇÒÉêÇë´óÐ¡²»³¬¹ýintmax('uint16')
                            if varargin{1}*varargin{2}>intmax('uint16')%ÊäÈë²ÎÊý¹ý´ó
                                dynObj.Value=zeros(intmax('uint8'),intmax('uint8'));%´´½¨¶ÔÏó
								disp(['²ÎÊý1£ºÐÐÊýÓë²ÎÊý2£ºÁÐÊýµÄ³Ë»ý¹ý´ó£¬³¬¹ýÁË',...
									num2str(intmax('uint16')),'£¬Ä¬ÈÏÉú³É´óÐ¡Îª',...
									num2str(intmax('uint8')),'x',num2str(intmax('uint8')),'µÄÊý×é¡£']);
                            else%ÊäÈë²ÎÊýÔÚ·¶Î§ÄÚ                 
                                dynObj.Value=zeros(uint16(varargin{1}),uint16(varargin{2}));%´´½¨¶ÔÏó
                            end
							dynObj.Type=0;%´æ´¢ÀàÐÍµ½×Ö¶Î£¬ÀàÐÍ£ºÊý×é
                        elseif ischar(varargin{2})%Êý×Ö¼Ó×Ö·û´®
                            switch varargin{2}
                                case 'array'%´ËÊ±¶¯Ì¬ÄÚ´æ¶ÔÏó±»¸³ÓèÎªÐÐÏòÁ¿£¬ÇÒ×î³¤³¤¶ÈÎªintmax('uint16')
                                    if varargin{1}>intmax('uint16')%ÊäÈë²ÎÊý¹ý´ó
                                        dynObj.Value=zeros(1,intmax('uint16'));%´´½¨¶ÔÏó
										disp(['²ÎÊý1£ºÁÐÊý¹ý´ó£¬³¬¹ýÁË',num2str(intmax('uint16')),...
											'£¬Ä¬ÈÏÉú³É´óÐ¡Îª1x',num2str(intmax('uint16'),'µÄÊý×é¡£')]);      
                                    else%ÊäÈë²ÎÊýÔÚ·¶Î§ÄÚ
                                        dynObj.Value=zeros(1,uint16(varargin{1}));%´´½¨¶ÔÏó
                                    end
									dynObj.Type=0;%´æ´¢ÀàÐÍµ½×Ö¶Î£¬ÀàÐÍ£ºÊý×é
									
                                case 'struct'%´ËÊ±¶¯Ì¬ÄÚ´æ¶ÔÏó±»¸³ÓèÎª½á¹¹ÌåÐÐÏòÁ¿£¬×î³¤³¤¶ÈÎªintmax('uint64')
                                    if varargin{1}>intmax('uint64')%ÊäÈë²ÎÊý¹ý´ó
                                        dynObj.Value(1,intmax('uint64'))=struct;%´´½¨¶ÔÏó,¶àÎ¬¶ÈÖ§³Öºó³¢ÊÔÓÃrepmat
										disp(['²ÎÊý1£ºÁÐÊý¹ý´ó£¬³¬¹ýÁË',num2str(intmax('uint64')),...
											'£¬Ä¬ÈÏÉú³É´óÐ¡Îª1x',num2str(intmax('uint64'),'µÄ½á¹¹ÌåÊý×é¡£')]);    
                                    else%ÊäÈë²ÎÊýÔÚ·¶Î§ÄÚ
                                        dynObj.Value(1,uint64(varargin{1}))=struct;%´´½¨¶ÔÏó
                                    end
									dynObj.Type=1;%´æ´¢ÀàÐÍµ½×Ö¶Î£¬ÀàÐÍ£º½á¹¹ÌåÊý×é

                                case 'cell'%´ËÊ±¶¯Ì¬ÄÚ´æ¶ÔÏó±»¸³ÓèÎªÏ¸°ûÐÐÏòÁ¿£¬ÇÒ×î³¤³¤¶ÈÎªintmax('uint16')
                                    if varargin{1}>intmax('uint16')%ÊäÈë²ÎÊý¹ý´ó
                                        dynObj.Value=cell(1,intmax('uint16'));%´´½¨¶ÔÏó
										disp(['²ÎÊý1£ºÁÐÊý¹ý´ó£¬³¬¹ýÁË',num2str(intmax('uint16')),...
											'£¬Ä¬ÈÏÉú³É´óÐ¡Îª1x',num2str(intmax('uint16'),'µÄÏ¸°ûÊý×é¡£')]); 
                                    else%ÊäÈë²ÎÊýÔÚ·¶Î§ÄÚ
                                        dynObj.Value=cell(1,varargin{1});%´´½¨¶ÔÏó
                                    end
									dynObj.Type=2;%´æ´¢ÀàÐÍµ½×Ö¶Î£¬ÀàÐÍ£ºÏ¸°ûÊý×é
									
                                otherwise%×Ö·û´®²»ÊÇÒÔÉÏÈýÖÖ
                                    dynObj.Value=zeros(1,intmax('uint16'));%´´½¨¶ÔÏó
                                    disp(['Ä¿Ç°Ö»Ö§³Ö''array''£¬''struct''£¬''cell''ÈýÖÖÀàÐÍµÄ¶¯Ì¬ÄÚ´æÉêÇë',...
                                        '£¬Ä¬ÈÏÉú³É´óÐ¡Îª1x',num2str(intmax('uint16'),'µÄÊý×é¡£')]); 
									dynObj.Type=0;%´æ´¢ÀàÐÍµ½×Ö¶Î£¬ÀàÐÍ£ºÊý×é	
                            end
                        else%µÚ¶þ¸ö²ÎÊý²»Âú×ãÌõ¼þ
                            disp('´´½¨¶ÔÏóÊ§°Ü£¬²ÎÊý2£ºÁÐÊý£¨Êý¾ÝÀàÐÍ£©±ØÐëÎªÒ»¸öÕýÊý£¨×Ö·û´®£©£¡');
                            return;
                        end
                    else%µÚÒ»¸ö²ÎÊý²»Âú×ãÌõ¼þ
                        disp('´´½¨¶ÔÏóÊ§°Ü£¬²ÎÊý1£ºÁÐÊý±ØÐëÎªÒ»¸öÕýÊý£¡');
                        return;
                    end

                case 3%µ±ÊäÈë²ÎÊýÎªÈý¸öÊ±£¬Ë³Ðò±ØÐëÊÇÊý×Ö£¬Êý×Ö£¬×Ö·û´®
                    if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0 ...
                            && isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0 ...
                            && ischar(varargin{3})%Âú×ãÕýÊýÕýÊý×Ö·û´®×éºÏ
                        switch varargin{3}
                            case 'array'%´ËÊ±¶¯Ì¬ÄÚ´æ¶ÔÏó±»¸³ÓèÎªÊý×é£¬ÇÒÉêÇë´óÐ¡²»³¬¹ýintmax('uint16')
                                if varargin{1}*varargin{2}>intmax('uint16')%ÊäÈë²ÎÊý¹ý´ó
                                    dynObj.Value=zeros(intmax('uint8'),intmax('uint8'));%´´½¨¶ÔÏó
									disp(['²ÎÊý1£ºÐÐÊýÓë²ÎÊý2£ºÁÐÊýµÄ³Ë»ý¹ý´ó£¬³¬¹ýÁË',...
										num2str(intmax('uint16')),'£¬Ä¬ÈÏÉú³É´óÐ¡Îª',...
										num2str(intmax('uint8')),'x',num2str(intmax('uint8')),'µÄÊý×é¡£']);
                                else%ÊäÈë²ÎÊýÔÚ·¶Î§ÄÚ                 
                                    dynObj.Value=zeros(uint16(varargin{1}),uint16(varargin{2}));%´´½¨¶ÔÏó
                                end
								dynObj.Type=0;%´æ´¢ÀàÐÍµ½×Ö¶Î£¬ÀàÐÍ£ºÊý×é

                            case 'struct'%´ËÊ±¶¯Ì¬ÄÚ´æ¶ÔÏó±»¸³ÓèÎª½á¹¹ÌåÊý×é£¬ÐÐÊýÓëÁÐÊý¶¼²»³¬¹ýintmax('uint64')
                                if varargin{1}>intmax('uint64') && varargin{2}<=intmax('uint64')%²ÎÊý1¹ý´ó
                                    dynObj.Value(intmax('uint64'),uint64(varargin{2}))=struct;%´´½¨¶ÔÏó
                                    disp(['²ÎÊý1£ºÐÐÊý¹ý´ó£¬³¬¹ýÁË',num2str(intmax('uint64')),...
										'£¬Ä¬ÈÏÉú³É´óÐ¡Îª',num2str(intmax('uint64')),'x',...
										num2str(uint64(varargin{2})),'µÄ½á¹¹ÌåÊý×é¡£']);
                                elseif varargin{1}<=intmax('uint64') && varargin{2}>intmax('uint64')%²ÎÊý2¹ý´ó
                                    dynObj.Value(uint64(varargin{1}),intmax('uint64'))=struct;%´´½¨¶ÔÏó
                                    disp(['²ÎÊý2£ºÁÐÊý¹ý´ó£¬³¬¹ýÁË',num2str(intmax('uint64')),...
										'£¬Ä¬ÈÏÉú³É´óÐ¡Îª',num2str(uint64(varargin{1})),'x',...
										num2str(intmax('uint64')),'µÄ½á¹¹ÌåÊý×é¡£']);
								elseif	varargin{1}>intmax('uint64') && varargin{2}>intmax('uint64')%²ÎÊý1,2¶¼¹ý´ó
                                    dynObj.Value(intmax('uint64'),intmax('uint64'))=struct;%´´½¨¶ÔÏó
                                    disp(['²ÎÊý1£ºÐÐÊýºÍ²ÎÊý2£ºÁÐÊý¶¼¹ý´ó£¬¶¼³¬¹ýÁË',num2str(intmax('uint64')),...
										'£¬Ä¬ÈÏÉú³É´óÐ¡Îª',num2str(uint64(varargin{1})),'x',...
										num2str(intmax('uint64')),'µÄ½á¹¹ÌåÊý×é¡£']);																								
                                else%ÊäÈë²ÎÊýÔÚ·¶Î§ÄÚ
                                    dynObj.Value(uint64(varargin{1}),uint64(varargin{2}))=struct;%´´½¨¶ÔÏó
                                end
								dynObj.Type=1;%´æ´¢ÀàÐÍµ½×Ö¶Î£¬ÀàÐÍ£º½á¹¹ÌåÊý×é
								
                            case 'cell'%´ËÊ±¶¯Ì¬ÄÚ´æ¶ÔÏó±»¸³ÓèÎªÏ¸°ûÊý×é£¬ÇÒÉêÇë´óÐ¡²»³¬¹ýintmax('uint16')
                                if varargin{1}*varargin{2}>intmax('uint16')%ÊäÈë²ÎÊý¹ý´ó
                                    dynObj.Value=cell(intmax('uint8'),intmax('uint8'));%´´½¨¶ÔÏó
									disp(['²ÎÊý1£ºÐÐÊýÓë²ÎÊý2£ºÁÐÊýµÄ³Ë»ý¹ý´ó£¬³¬¹ýÁË',...
										num2str(intmax('uint16')),'£¬Ä¬ÈÏÉú³É´óÐ¡Îª',...
										num2str(intmax('uint8')),'x',num2str(intmax('uint8')),'µÄÏ¸°ûÊý×é¡£']);
                                else%ÊäÈë²ÎÊýÔÚ·¶Î§ÄÚ                 
                                    dynObj.Value=cell(uint16(varargin{1}),uint16(varargin{2}));%´´½¨¶ÔÏó
                                end
								dynObj.Type=2;%´æ´¢ÀàÐÍµ½×Ö¶Î£¬ÀàÐÍ£ºÏ¸°ûÊý×é

                            otherwise%×Ö·û´®²»ÊÇÒÔÉÏÈýÖÖ
                                dynObj.Value=zeros(intmax('uint8'),intmax('uint8'));%´´½¨¶ÔÏó
								disp(['Ä¿Ç°Ö»Ö§³Ö''array''£¬''struct''£¬''cell''ÈýÖÖÀàÐÍµÄ¶¯Ì¬ÄÚ´æÉêÇë',...
									'£¬Ä¬ÈÏÉú³É´óÐ¡Îª',num2str(intmax('uint8'),'x',...
									num2str(intmax('uint8')),'µÄÊý×é¡£')]); 
								dynObj.Type=0;%´æ´¢ÀàÐÍµ½×Ö¶Î£¬ÀàÐÍ£ºÊý×é	
                        end
                    else%²ÎÊýÅÅÁÐ×éºÏ²»Âú×ãÌõ¼þ
                        disp(['´´½¨¶ÔÏóÊ§°Ü£¬'...
							'²ÎÊý1£ºÁÐÊý±ØÐëÎªÒ»¸öÕýÊý£¬',...
                            '²ÎÊý2£ºÐÐÊý±ØÐëÎªÒ»¸öÕýÊý£¬',...
                            '²ÎÊý3£ºÊý¾ÝÀàÐÍ±ØÐëÎªÒ»¸ö×Ö·û´®£¡']);
                        return;
                    end

                otherwise%µ±ÊäÈë²ÎÊý¹ý¶àÊ±
                    disp('´´½¨¶ÔÏóÊ§°Ü£¬ÊäÈë²ÎÊý¹ý¶à£¡');
                    return;
            end
			dynObj.OriginalSize=size(dynObj.Value);%±£´æÔ­Ê¼´óÐ¡µ½×Ö¶Î
        end	
    end
    
	
    methods%¹«¿ªº¯Êý
        function dynObj=refresh(dynObj,varargin)
        %refresh:·ÃÎÊ¶ÔÏóÄÚÄÚ´æÄ©¶Ë×îºóÒ»ÏµÁÐÊý×ÖÊÇ·ñÎª0£¬Èç¹ûÓÐÊý×Ö¸ü¸Ä¹ý£¬
		%		    ÔòÉêÇë¸ü´óµÄÄÚ´æÓÐ¿ÉÄÜ»áÒòÎª±¾ÉíÊý×é×îºóÒ»ÏµÁÐÊý×ÖÎª0¶øË¢ÐÂÊ§°Ü£¬
		%		    »áÒò´Ë¶øÔÝÊ±½µµÍÐ§ÂÊ£¬Ò»µ©ÓÐ·Ç0Êý×ÖÊäÈë£¬»áÂíÉÏÌá¸ßÐ§ÂÊ
		%dynObj:±»´¦ÀíµÄ¶¯Ì¬ÄÚ´æ¶ÔÏó£¬¿ÉÄÜÓÐ³¤¶ÈµÄÀ©ÈÝ
		%varargin:¿ÉÑ¡µÄÊäÈë£¬¿ÉÒÔÉèÖÃÑ­»·¼ì²âµÄ³¤¶È±ÈÀý£¬·¶Î§ÔÚ0~1Ö®¼ä£¬Ô½½Ó½ü1£¬
		%		      ¼ì²âµÄ·¶Î§¾ÍÔ½Ð¡£¬µ±²»ÊäÈëÊ±£¬Ä¬ÈÏÎª0.9
        %versin:1.0.0
        %author:jinshuguangze
        %data:4/17/2018	
		%TODO:¿¼ÂÇ²¢·ÇÊ¹ÓÃ³¤¶È±ÈÀý£¬¶øÊ¹ÓÃ¹Ì¶¨ÊýÖµ
		%¿¼ÂÇ¶àÎ¬Çé¿ö£¬¿ÉÒÔÊäÈë¶à¸ö²ÎÊý
        %Èë¿Ú¼ì²â
        
            para=dynObj.Scale;%³¤¶È±ÈÀýµÄÄ¬ÈÏÖµÉèÖÃÎªScale
            if nargin==1%²»ÊäÈëÊ±£¬ÉèÖÃÄ¬ÈÏÖµ
            elseif nargin==2%ÊäÈëÒ»¸ö¶îÍâ²ÎÊý
                if varargin{1}>0 && varargin{1}<1%¼ì²â·¶Î§ÊÇ·ñÂú×ã
                    para=varargin{1};
                else%²»Âú×ãµ¯³öÌáÊ¾£¬²¢ÉèÖÃ³ÉÄ¬ÈÏÖµ
                    disp('²ÎÊý1£º³¤¶È±ÈÀý²»Âú×ãÔÚ0~1·¶Î§ÄÚ£¬ÒÑÉèÖÃ³ÉÄ¬ÈÏÖµ£º',num2str(para),'¡£');
                end
            else%ÊäÈë²ÎÊý¹ý¶à
                disp('Ë¢ÐÂ¶ÔÏóÊ§°Ü£¬Ô­Òò£ºÊäÈë²ÎÊý¹ý¶à£¡');
                return;
            end
			
			[row,col]=size(dynObj.Value);%»ñÈ¡¶ÔÏóÐÐÊýºÍÁÐÊý		
			switch dynObj.Type%¶ÔÓÚ¶ÔÏóµÄ²»Í¬ÀàÐÍÓÐ²»Í¬´¦Àí			
				case 0%Èç¹û¶ÔÏóÊÇÊý×é
					for i=row:-1:ceil(para*row)
						for j=col:-1:ceil(para*col)
							if dynObj.Value(i,j)%·ÃÎÊÊý×é¸ÃË÷ÒýÏÂµÄÖµÊÇ·ñÎª0
								dynObj=dynObj.addMemory;
                                return;
							end
						end
					end
					
				case 1%Èç¹û¶ÔÏóÊÇ½á¹¹ÌåÊý×é£¬ÓÐÌØÊâÐÔ£¬Òª·ÃÎÊ×Ö¶Î
					fields=fieldnames(dynObj.Value);
					if size(fields,1)%È·±£½á¹¹ÌåÊý×éÖÁÉÙÓÐÒ»¸ö×Ö¶Î
						for k=1:size(fields,1)
							for i=row:-1:ceil(para*row)
								for j=col:-1:ceil(para*col)
									if ~isempty(getfield(dynObj.Value(i,j),fields{i,1}))%·ÃÎÊÃ¿¸ö×Ö¶ÎµÄÖµÊÇ·ñÎª¿Õ
										dynObj=dynObj.addMemory;
                                        return;
									end
								end
							end
						end
					end
					
				case 2%Èç¹û¶ÔÏóÊÇÏ¸°ûÊý×é
					for i=row:-1:ceil(para*row)
						for j=col:-1:ceil(para*col)
							if ~isempty(dynObj.Value{i,j})%·ÃÎÊ¸ÃÏ¸°ûÊý×é×éÔªÏÂµÄÖµÊÇ·ñÎª¿Õ
								dynObj=dynObj.addMemory;
                                return;
							end
						end
					end
					
				otherwise%Èç¹û¶ÔÏóÊÇÎ´ÖªÀàÐÍ£¬³ý·ÇÔâµ½¶ñÒâ´Û¸Ä£¬·ñÔò²»»á·¢Éú
                    clear dynObj;
					disp('Ë¢ÐÂ¶ÔÏóÊ§°Ü£¬Ô­Òò£º¶ÔÏó×´Ì¬Òì³££¬ÒÑ¾­×Ô»Ù£¡');						
					return;
			end
        end       
        
		
        function dynObj=addMemory(dynObj,varargin)
        %addMemory:ÓÉÓÚº¯ÊýÊÇ¹«¿ªµÄ£¬ËùÒÔ¿ÉÒÔÊÖ¶¯È¥ÉêÇë¸ü´óµÄÄÚ´æ£¬
		%                  Ä¬ÈÏÎªÔö¼ÓÐÐÊý£¬ÊýÖµÎª³õÊ¼ÉêÇëÄÚ´æµÄÐÐÊý
        %dynObj:±»´¦ÀíµÄ¶¯Ì¬ÄÚ´æ¶ÔÏó£¬³¤¶ÈÒÑ¾­Ôö¼Ó
		%varargin:¿ÉÑ¡µÄÊäÈë£¬¿ÉÒÔ¸ù¾ÝÊäÈëÀ´ÉèÖÃÔö¼ÓÖµµÄ´óÐ¡£¬
		%             »òÕßÑ¡ÔñÔö¼ÓµÄ·½ÏòÊÇÐÐ»òÕßÁÐ£¬»òÕß¶¼ÉèÖÃ
        %versin:1.0.2
        %author:jinshuguangze
        %data:4/17/2018	
		%TODO:
		%1.¶àÎ¬¶ÈÔö¼ÓÖ§³Ö£¨¶ø²»ÊÇÁ½Î¬¶È£©£º('D1',2,'D2',4,'D5',9,10<-Õâ¸öÄ¬ÈÏÎªÇ°ÃæÈ·¶¨Î¬¶ÈµÄºóÒ»Î¬£¬¼´D6)	
		%2.Èç¹û¶ÔÏóÎ¬¶ÈºÍ´óÐ¡¸Ä±äÁË£¬catº¯Êý»áÁé»îµ÷Õû£¬Èç¹ûÊÇdim·½ÏòÉÏµÄÆ´½Ó£¬Ôò±ØÐë±£Ö¤³ýÁËdim£¬ÆäËû´óÐ¡¶¼ÒªÂú×ã	
		%	for i=1:nargin
		%		if ischar(varargin{i}) && ...×Ö·ûÆ´½ÓÏà¹Ø	
		
			dim=1;%·½ÏòÄ¬ÈÏÎªÐÐÊý·½Ïò
			rowadd=dynObj.OriginalSize(1);%ÐÐÊýÄ¬ÈÏÔö¼ÓorignalRow
			coladd=0;%ÁÐÊýÄ¬ÈÏÔö¼Ó0
			if nargin==1%Èç¹ûÎÞ²ÎÊýÊäÈë£¬½á¹ûÎªÄ¬ÈÏ			
			elseif nargin==2%Èç¹ûÓÐÒ»¸ö²ÎÊýÊäÈë£¬ÓÐ¿ÉÄÜÊÇÒ»¸ö¾ö¶¨Ôö¼Ó·½ÏòµÄ×Ö·û´®£¬»òÕßÊÇ¾ö¶¨Ôö¼ÓÊýÖµµÄÕýÊý
				if ischar(varargin{1})%Âú×ãÊÇ¸ö×Ö·û´®
					if varargin{1}=='col'
						dim=1;%·½Ïò¸ÄÎªÔö¼ÓÁÐÊý
					else
						disp('²ÎÊý1£º·½Ïò±ØÐëÎª''row''ºÍ''col''ÆäÖÐÖ®Ò»£¬ÒÑÉèÖÃ³ÉÄ¬ÈÏÖµ£ºµÚÒ»Î¬¶È¡£');
					end
				elseif isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0%Âú×ãÊÇ¸öÕýÊý
					rowadd=uint16(varargin{1});%ÐÞ¸ÄÔö¼ÓÐÐÊý
				else%Èç¹û²»Âú×ãÌõ¼þ
					disp('Ôö¼ÓÄÚ´æÊ§°Ü£¬Ô­Òò£º²ÎÊý1£º·½Ïò£¨Ôö¼ÓÐÐÊý£©±ØÐëÎª×Ö·û´®£¨ÕýÊý£©£¡');
					return;
				end
			elseif nargin==3%Èç¹ûÓÐÁ½¸ö²ÎÊýÊäÈë£¬±ØÐëÎªÁ½¸öÕýÊý
				if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0 ...
                    && isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0%Á½¸öÕýÊý
					rowadd=unit16(varargin{1});%ÉèÖÃÐÐÊýÔö¼ÓÖµ
					coladd=unit16(varargin{2});%ÉèÖÃÁÐÊýÔö¼ÓÖµ
				else
					disp('Ôö¼ÓÄÚ´æÊ§°Ü£¬Ô­Òò£º²ÎÊý1£ºÔö¼ÓÐÐÊýÓë²ÎÊý2£ºÔö¼ÓÁÐÊý±ØÐë¶¼ÎªÕýÊý£¡');
					return;
				end	
			else%²ÎÊýÊäÈë¹ý¶à
				disp('Ôö¼ÓÄÚ´æÊ§°Ü£¬Ô­Òò£ºÊäÈë²ÎÊý¹ý¶à£¡');
				return;
			end
			
            switch dynObj.Type%¶ÔÓÚ¶ÔÏóµÄ²»Í¬ÀàÐÍÓÐ²»Í¬´¦Àí
				case 0%Èç¹û¶ÔÏóÊÇÊý×é
					newMemory=zeros(dynObj.OriginalSize);
					
				case 1%Èç¹û¶ÔÏóÊÇ½á¹¹ÌåÊý×é
					newMemory=repmat(struct,dynObj.OriginalSize);
					
				case 2%Èç¹û¶ÔÏóÊÇÏ¸°ûÊý×é
					newMemory=cell(dynObj.OriginalSize);
					
				otherwise
					dynObj.free;	
					disp('Ôö¼ÓÄÚ´æÊ§°Ü£¬Ô­Òò£º¶ÔÏó×´Ì¬Òì³££¬ÒÑ¾­×Ô»Ù£¡');						
					return;
            end
			dynObj.Value=cat(dim,dynObj.Value,newMemory);%Æ´½ÓÊý×é			
        end                    
    end
    
    methods%set,get·½·¨¼¯ºÏ
        function value=get.Value(dynObj)
            value=dynObj.Value;
        end
        
        function dynObj=set.Value(dynObj,value)
            dynObj.Value=value;
        end
        
        function originalSize=get.OriginalSize(dynObj)
            originalSize=dynObj.OriginalSize;
        end
        
        function dynObj=set.OriginalSize(dynObj,originalSize)
            dynObj.OriginalSize=originalSize;
        end
        
        function type=get.Type(dynObj)
            type=dynObj.Type;
        end
        
        function dynObj=set.Type(dynObj,type)
            dynObj.Type=type;
        end     
    end
    
>>>>>>> 45c2f446b7e2900776a7fea54c7ce62d99658884
end