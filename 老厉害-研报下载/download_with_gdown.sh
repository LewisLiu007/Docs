#!/bin/bash

# 设置代理
export http_proxy="http://proxy.sha.sap.corp:8080"
export https_proxy="http://proxy.sha.sap.corp:8080"
export HTTP_PROXY="http://proxy.sha.sap.corp:8080"
export HTTPS_PROXY="http://proxy.sha.sap.corp:8080"

OUTPUT_DIR="/Users/C5406917/repos/github-lewisliu007/docs/研报下载/reports"
mkdir -p "$OUTPUT_DIR"

cd "$OUTPUT_DIR"

count=0
total=$(wc -l < /Users/C5406917/repos/github-lewisliu007/docs/研报下载/drive_links.txt | tr -d ' ')

echo "开始下载研报，共 $total 个文件..."
echo ""

while IFS= read -r url; do
    ((count++))
    # 提取文件ID
    file_id=$(echo "$url" | sed 's|https://drive.google.com/file/d/||')
    
    echo "[$count/$total] 下载文件 ID: $file_id"
    
    # 使用gdown下载
    gdown --fuzzy "https://drive.google.com/file/d/${file_id}/view" -O "report_${count}.pdf" 2>&1 | head -5
    
    # 检查是否下载成功
    if [ -f "report_${count}.pdf" ]; then
        size=$(stat -f%z "report_${count}.pdf" 2>/dev/null || stat -c%s "report_${count}.pdf" 2>/dev/null)
        if [ "$size" -lt 1000 ]; then
            echo "  警告: 文件太小 ($size bytes)，可能下载失败，尝试重命名"
            # 检查是否有其他格式的文件被下载
            latest_file=$(ls -t | head -1)
            if [ "$latest_file" != "report_${count}.pdf" ] && [ -n "$latest_file" ]; then
                echo "  发现文件: $latest_file"
            fi
        else
            echo "  成功: 文件大小 $size bytes"
        fi
    else
        # 检查是否有其他名称的文件被下载
        latest_file=$(ls -t 2>/dev/null | head -1)
        if [ -n "$latest_file" ]; then
            echo "  发现下载的文件: $latest_file"
        fi
    fi
    
    echo ""
    sleep 1
done < /Users/C5406917/repos/github-lewisliu007/docs/研报下载/drive_links.txt

echo "下载完成！"
echo "文件保存在: $OUTPUT_DIR"
echo ""
echo "下载的文件列表:"
ls -la "$OUTPUT_DIR"