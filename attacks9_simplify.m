function name = attacks9_simplify(originshpfile, outshpfile, charug)
    % attacks9_simplify - ʹ�õ�����˹-�տ��㷨��ʸ����ͼ
    %
    % �ú����������ʸ����ͼ�ļ�ִ��ѹ���򻯲������Լ��ٵ�����
    %
    % ���������
    %   originshpfile - ����� .shp �ļ�·��
    %   outshpfile - ����� .shp �ļ���
    %   charug - �򻯵���ֵ���������ڿ��Ƶ�����˹-�տ��㷨�ļ򻯳̶�
    %
    % ���������
    %   name - ���澭���򻯺����ʸ����ͼ�ļ�������·����

    originshpfile = shaperead(originshpfile);

    % ����ѹ����ֵ
    % if nargin < 3
    %     charug = 5; % Ĭ����ֵ�����δָ��
    % end

    % ��ʼ��������
    oCount = 0; % ԭʼ������
    sCount = 0; % �򻯺�ĵ�����
    simplifiedShp = originshpfile; % ��ʼ���򻯺�����ݽṹ

    % ����ÿ������Ҫ�ز����м�
    for i = 1:length(originshpfile)
        % ��ȡ��ǰ����Ҫ�ص� X �� Y ���꣬�ų� NaN ֵ
        xarray = originshpfile(i).X(~isnan(originshpfile(i).X))';
        yarray = originshpfile(i).Y(~isnan(originshpfile(i).Y))';

        % �ϲ� X �� Y ����Ϊ��ά������
        xys = [xarray, yarray];

        % ʹ�õ�����˹-�տ��㷨��ȡ�򻯺��������
        [pts, ids] = Douglas(xys, charug); % ���� Douglas ����
        ids = ids'; % ת�� ids �Ա�ʹ��

        % ����ԭʼ�ͼ򻯺�ĵ����
        oCount = oCount + length(yarray);
        sCount = sCount + length(ids);

        % ���򻯺�����긳ֵ���򻯵ĵ���Ҫ�ؽṹ
        simplifiedShp(i).X = xarray(ids);
        simplifiedShp(i).Y = yarray(ids);
    end

    % ����ѹ������
    deletefactorstr = 1 - sCount / oCount;

    % ��������ļ�·���������򻯱�����Ϣ
    name = fullfile('attacked', 'simplify', ['simplify_', num2str(deletefactorstr), '_', outshpfile]);

    % ����򻯺�� shapefile �ļ�
    shapewrite(simplifiedShp, name);
    fprintf('ʸ����ͼ����ɣ��ļ��ѱ��浽 %s\n', name);
end
