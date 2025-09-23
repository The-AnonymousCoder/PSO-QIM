function embedshp = sdwt_embed_check(originshpfile, outshpfile, watermarkImg,checkIter)


% �������ⶥ���ˮӡ�㷨
% �������ߺ���

% clc;            % ��������д���
% clear;          % ����������е����б���
% close all;          % �ر����д򿪵�ͼ�δ���
tic;            % ��ʼ��ʱ�������������ʱ��  landuse  hyda3857  building  waterways  output

originshpfile=shaperead(originshpfile);         % ��ȡshapefile�е���״����

wo = watermarkImg;                % ����ˮӡͼƬ���ļ���
wo=im2bw(imread(wo));           % ��ȡˮӡͼƬ������ת��Ϊ��ֵͼ��

M =size(wo);                            % ��ȡˮӡͼ��ĳߴ�
watermarkLength = M(1)*M(2);            % ����ˮӡ�ĳ��ȣ�����������
w=logisticE(wo,0.98);                   % ʹ��logisticӳ������һ�����ܵ�ˮӡ����




% ��ʾԭʼˮӡͼ��ͼ��ܺ��ˮӡͼ��
% figure;                     % ����һ���µ�ͼ�δ���
% subplot(2, 1, 1);               % ��ͼ�δ��ڷֳ�����һ�У��ڵ�һ��λ����ʾԭʼˮӡͼ��
% imshow(wo);                 % ��ʾԭʼˮӡͼ��
%
% subplot(2, 1, 2);           % �ڵڶ���λ����ʾ���ܺ��ˮӡͼ��
% imshow(w);                  % ��ʾ���ܺ��ˮӡͼ��


virtualCount=3;             % ���ⶥ��ĸ�������Ϊ����
R=3*10^-2;                  % ��������R�����ڿ���ˮӡǶ��ľ���
Mcof = 10^6;                % ��ϵ�������ڱ�������
watermarkedShp=originshpfile;        % ��ʼ��ˮӡ���shapefile��������Ϊԭʼshapefile

% ����shapefile�е�ÿ����״������ˮӡǶ��
for i=1:length(originshpfile)


    xarray = originshpfile(i).X;        % ��ȡ��i����״��X��������
    yarray =  originshpfile(i).Y;       % ��ȡ��i����״��Y��������
    xnotnanindex=find(~isnan(xarray));  % �ҳ�X�����з�NaNֵ������
    ynotnanindex=find(~isnan(yarray));  % �ҳ�X�����з�NaNֵ������
    xarray=xarray(xnotnanindex)';       % ȥ��X�����е�NaNֵ��ת��Ϊ������
    yarray=yarray(ynotnanindex)';       % ȥ��Y�����е�NaNֵ��ת��Ϊ������


    if (length(xarray)==0)          % ���û����Ч��X�������ݣ������������״
        continue
    end
    xys=[xarray  yarray];           % ��X��Y������ϳ�һ������


    [LX,HX] = sdwt(xys(:,1)');      % ��X���������ɢС���任���õ���Ƶ�͸�Ƶϵ��
    [LY,HY] = sdwt(xys(:,2)');      % ��Y���������ɢС���任���õ���Ƶ�͸�Ƶϵ��

    HX_mod=[];                      % ��ʼ���޸ĺ��X��Ƶϵ������


    y_norm = (yarray - min(yarray)) / (max(yarray) - min(yarray)); % ��һ���� [0, 1] ��Χ
    % y_norm = yarray;
    pList = [];

    % ���������������ƣ�QIM��Ƕ��ˮӡ
    for n=1:length(HX)
        if(HY(n)==0)            % ���Y����ĸ�Ƶϵ��Ϊ0���������õ�
            HX_mod(n)=HX(n)*Mcof;        % ���õ��X�����Ƶϵ������Mcof������ˮӡ�޸�
            continue;
        end
        ratioLXY = HX(n) / HY(n);           % ����X��Y�����Ƶϵ���ı���
        ratioLXY_forrecord=ratioLXY;        % ��¼ԭʼ���ʣ�������Ժͷ���
        p = mod(floor(ratioLXY*100000), watermarkLength) + 1;
        pList = [pList,p];
        ratioLXY = ratioLXY*Mcof;           % ���ʳ���Mcof���б�������
        %         p=mod(floor(ratioLXY/100),watermarkLength)+1;  yarray(n)*100000
        % p = mod(floor(ratioLXY/100), watermarkLength) + 1;
        % ����ˮӡֵ�������ʣ�ʹ�øö����X�����Ƶϵ��Ƕ��ˮӡ
        if w(p)==0 &&  mod(ratioLXY,R)>R/2         % ���ˮӡλΪ0�ұ��ʵ�ģ����R/2����ȥR/2
            ratioLXY=ratioLXY-R/2;
        elseif w(p)==1 && mod(ratioLXY,R)<R/2       % ���ˮӡλΪ1�ұ��ʵ�ģС��R/2������R/2
            ratioLXY=ratioLXY+R/2;
        end
        HX_mod(n)=ratioLXY*HY(n);           % ���޸ĺ�ı��ʳ���Y�����Ƶϵ��������X�����Ƶϵ��
    end


            % p=round(y_norm(n) * (watermarkLength - 1)) + 1;   % ���ݵ�ǰ�����Y�����ˮӡ���ȼ���Ƕ���λ��p
        % p = mod(floor(HY(n) * 100000000), watermarkLength) + 1;

    % ����NP

    % ÿ�����ӵ����Լ���  ��ʼ�� ��Ƶϵ��modifiedCoefficients
    % N = length(HX);  % ��Ƶϵ������
    % negative_count = 0;
    % fitness = 0;
    % modifiedCoefficients = ratioLXY;
    % HX_mod = zeros(1, N);
    % X_embedded = 0;
    % 
    % % ˮӡǶ���ĸ�Ƶϵ��
    % for i = 1:N
    %     if HY(i) == 0  % ���Y����ĸ�Ƶϵ��Ϊ0���������õ�
    %         HX_mod(i) = HX(i) * Mcof;  % ���õ��X�����Ƶϵ������Mcof������ˮӡ�޸�
    %         continue;
    %     end
    %     % modifiedCoefficients(i) = modifiedCoefficients(i) + positions(g, i);
    %     HX_mod(i)=modifiedCoefficients(i)*HY(i);
    % end
    % 
    % % ���㵱ǰ�����ӵ����Ը���(��Ӧ��)
    % HX_mod =  HX_mod/Mcof;              % ��X�����Ƶϵ������Mcof���ָ�����
    % % �ñ任��ȥ��H_WVV��ȥ����ˮӡ��������
    % X_embedded = isdwt(LX,HX_mod);      % ͨ������ɢС���任��IDWT���õ��޸ĺ��X����
    % [LX_CVV,HX_CVV] = sdwt(X_embedded);         % ��X���������ɢС���任
    % for i=1:N-1
    %     H_WVV=ratioLXY(i);
    %     H_CVV= (HX_CVV(i) / HY(i)) * Mcof;
    % 
    %     label_H_WVV = (mod(H_WVV, R) >= R / 2);
    %     label_H_CVV = (mod(H_CVV, R) >= R / 2);
    %     % �ж�������������Ƿ���ͬһ��ǩ����
    %     if label_H_WVV == label_H_CVV
    %         negative_count = negative_count + 1;
    %     end
    % end
    % fitness = negative_count / N;  % ��Ӧ�ȣ����Ը���
    % 
    % fprintf('NP��Ӧ�� = %.4f\n', fitness);

    % ����NP




    HX_mod =  HX_mod/Mcof;              % ��X�����Ƶϵ������Mcof���ָ�����
    X_embedded = isdwt(LX,HX_mod);      % ͨ������ɢС���任��IDWT���õ��޸ĺ��X����



    if checkIter~=0
        for iter=1:checkIter
            X_embedded = watermarkCoor(X_embedded,yarray,HY,w,watermarkLength,R,Mcof);
            % X_embedded = watermarkCoor(X_embedded,yarray,HY,w,watermarkLength,R,Mcof);
            % X_embedded = watermarkCoor(X_embedded,yarray,HY,w,watermarkLength,R,Mcof);
            % X_embedded = watermarkCoor(X_embedded,yarray,HY,w,watermarkLength,R,Mcof);
            % X_embedded = watermarkCoor(X_embedded,yarray,HY,w,watermarkLength,R,Mcof);
            % X_embedded = watermarkCoor(X_embedded,yarray,HY,w,watermarkLength,R,Mcof);
            % X_embedded = watermarkCoor(X_embedded,yarray,HY,w,watermarkLength,R,Mcof);

        end

    end

    % ȷ����β��һ��
    % if strcmp(originshpfile(i).Geometry, 'Polygon')  && ~isequal(X_embedded(1), X_embedded(end))
    %     X_embedded(end+1) = X_embedded(1);  % ���׵���ӵ�β��
    %     yarray(end+1) = yarray(1);          % ���׵���ӵ�β��
    % end



    % ����ˮӡ���shapefile��X��Y����
    watermarkedShp(i).X = X_embedded;
    watermarkedShp(i).Y =yarray';

end

% ����ˮӡǶ��ǰ����״���������ƽ�����
[max_error,mean_error,~,~] = SuperError(watermarkedShp,originshpfile)
% ����Ƕ��ˮӡ���shapefile
embedshp=strcat('Embed/Embed_normal_',outshpfile);      % ��������ļ�·��
shapewrite(watermarkedShp,embedshp );           % д���µ�shapefile

toc;            % ������ʱ�������������ʱ��



% ����watermarkCoor��������һ������Ƕ���ˮӡ
    function X_embedded = watermarkCoor(xs,ys,HY,w,watermarkLength,R,Mcof)

        [LX_check,HX_check] = sdwt(xs);         % ��X���������ɢС���任
        HX_check_mod  = HX_check;               % ��ʼ���޸ĺ�ĸ�Ƶϵ������

        % �Ը�Ƶϵ�����е�����Ƕ��ˮӡ
        for n=1:length(HX_check)
            if(HY(n)==0)  % ���Y����ĸ�Ƶϵ��Ϊ0���������õ�
                HX_check_mod(n)=HX_check(n)*Mcof;
                continue;
            end
            % ����X��Y�����Ƶϵ���ı���
            ratioLXY = HX_check(n) / HY(n);

            p = mod(floor(ratioLXY*100000), watermarkLength) + 1;

            ratioLXY = ratioLXY*Mcof;       % �����ʳ���Mcof���б�������
            %         p=mod(floor(ratioLXY/100),watermarkLength)+1;
            %
            % ����Y�����ˮӡ���ȼ���Ƕ���λ��p
            % p=mod(floor(ys(n)*100000),watermarkLength)+1;


            % ����ˮӡֵ�������ʣ�ʹ�øö����X�����Ƶϵ��Ƕ��ˮӡ
            if w(p)==0 &&  mod(ratioLXY,R)>R/2
                ratioLXY=ratioLXY+R/2;      % ���ˮӡλΪ0�ұ��ʵ�ģ����R/2����ȥR/2
            elseif w(p)==1 && mod(ratioLXY,R)<R/2
                ratioLXY=ratioLXY+R/2;      % ���ˮӡλΪ1�ұ��ʵ�ģС��R/2������R/2
            end
            HX_check_mod(n)=ratioLXY*HY(n);     % ���޸ĺ�ı��ʳ���Y�����Ƶϵ��������X�����Ƶϵ��
        end
        HX_check_mod =  HX_check_mod/Mcof;      % ����Ƶϵ������Mcof���ָ�����
        X_embedded = isdwt(LX_check,HX_check_mod);      % ͨ������ɢС���任��IDWT���õ��޸ĺ��X����

    end

end


