// Kiro 凭据上传功能模块

import { showToast } from './utils.js';

let selectedFile = null;

/**
 * 初始化 Kiro 上传功能
 */
export function initKiroUpload() {
    const uploadBtn = document.getElementById('uploadKiroCredsBtn');
    const modal = document.getElementById('uploadKiroModal');
    const closeBtn = modal?.querySelector('.modal-close');
    const cancelBtn = document.getElementById('cancelKiroUpload');
    const confirmBtn = document.getElementById('confirmKiroUpload');
    const selectFileBtn = document.getElementById('selectKiroFileBtn');
    const fileInput = document.getElementById('kiroFileInput');
    const uploadArea = document.getElementById('kiroUploadArea');
    const removeFileBtn = document.getElementById('removeKiroFile');

    if (!uploadBtn || !modal) return;

    // 打开模态框
    uploadBtn.addEventListener('click', () => {
        modal.style.display = 'flex';
        resetUploadForm();
    });

    // 关闭模态框
    const closeModal = () => {
        modal.style.display = 'none';
        resetUploadForm();
    };

    closeBtn?.addEventListener('click', closeModal);
    cancelBtn?.addEventListener('click', closeModal);

    // 点击模态框外部关闭
    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            closeModal();
        }
    });

    // 选择文件按钮
    selectFileBtn?.addEventListener('click', () => {
        fileInput?.click();
    });

    // 文件选择
    fileInput?.addEventListener('change', (e) => {
        const file = e.target.files[0];
        if (file) {
            handleFileSelect(file);
        }
    });

    // 拖拽上传
    uploadArea?.addEventListener('dragover', (e) => {
        e.preventDefault();
        uploadArea.classList.add('drag-over');
    });

    uploadArea?.addEventListener('dragleave', () => {
        uploadArea.classList.remove('drag-over');
    });

    uploadArea?.addEventListener('drop', (e) => {
        e.preventDefault();
        uploadArea.classList.remove('drag-over');
        
        const file = e.dataTransfer.files[0];
        if (file) {
            handleFileSelect(file);
        }
    });

    // 移除文件
    removeFileBtn?.addEventListener('click', () => {
        resetUploadForm();
    });

    // 确认上传
    confirmBtn?.addEventListener('click', async () => {
        if (!selectedFile) {
            showToast('请先选择文件', 'error');
            return;
        }

        await uploadKiroCredentials();
    });
}

/**
 * 处理文件选择
 */
function handleFileSelect(file) {
    // 验证文件类型
    if (!file.name.endsWith('.json')) {
        showToast('请选择 JSON 文件', 'error');
        return;
    }

    // 验证文件大小（最大 1MB）
    if (file.size > 1024 * 1024) {
        showToast('文件大小不能超过 1MB', 'error');
        return;
    }

    selectedFile = file;

    // 显示文件信息
    const fileInfo = document.getElementById('kiroFileInfo');
    const fileName = document.getElementById('kiroFileName');
    const uploadArea = document.getElementById('kiroUploadArea');
    const confirmBtn = document.getElementById('confirmKiroUpload');

    if (fileInfo && fileName && uploadArea && confirmBtn) {
        fileName.textContent = file.name;
        uploadArea.style.display = 'none';
        fileInfo.style.display = 'flex';
        confirmBtn.disabled = false;
    }

    // 读取并验证文件内容
    validateKiroFile(file);
}

/**
 * 验证 Kiro 凭据文件
 */
async function validateKiroFile(file) {
    try {
        const text = await file.text();
        const data = JSON.parse(text);

        // 验证必需字段
        const requiredFields = ['clientId', 'clientSecret', 'accessToken', 'refreshToken'];
        const missingFields = requiredFields.filter(field => !data[field]);

        if (missingFields.length > 0) {
            showToast(`文件缺少必需字段: ${missingFields.join(', ')}`, 'error');
            resetUploadForm();
            return false;
        }

        // 检查是否有重复的 expiresAt 字段
        const jsonStr = JSON.stringify(data);
        const expiresAtCount = (jsonStr.match(/"expiresAt"/g) || []).length;
        if (expiresAtCount > 1) {
            showToast('文件格式错误：包含重复的 expiresAt 字段', 'error');
            resetUploadForm();
            return false;
        }

        showToast('文件验证通过', 'success');
        return true;
    } catch (error) {
        showToast('文件格式错误：' + error.message, 'error');
        resetUploadForm();
        return false;
    }
}

/**
 * 上传 Kiro 凭据
 */
async function uploadKiroCredentials() {
    const confirmBtn = document.getElementById('confirmKiroUpload');
    const accountNameInput = document.getElementById('kiroAccountName');
    const accountName = accountNameInput?.value.trim() || `kiro-${Date.now()}`;

    if (!selectedFile) return;

    try {
        confirmBtn.disabled = true;
        confirmBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 上传中...';

        // 创建 FormData
        const formData = new FormData();
        formData.append('file', selectedFile);
        formData.append('provider', 'claude-kiro-oauth');
        formData.append('accountName', accountName);

        // 上传文件
        const response = await fetch('/api/upload-oauth-credentials', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('authToken')}`
            },
            body: formData
        });

        const result = await response.json();

        if (response.ok && result.success) {
            showToast('Kiro 凭据上传成功！', 'success');
            
            // 关闭模态框
            document.getElementById('uploadKiroModal').style.display = 'none';
            resetUploadForm();

            // 刷新提供商列表
            if (window.loadProviders) {
                setTimeout(() => window.loadProviders(), 1000);
            }

            // 刷新配置
            if (window.loadConfig) {
                setTimeout(() => window.loadConfig(), 1500);
            }
        } else {
            showToast(result.message || '上传失败', 'error');
        }
    } catch (error) {
        console.error('上传错误:', error);
        showToast('上传失败: ' + error.message, 'error');
    } finally {
        confirmBtn.disabled = false;
        confirmBtn.innerHTML = '<i class="fas fa-upload"></i> 上传并添加到号池';
    }
}

/**
 * 重置上传表单
 */
function resetUploadForm() {
    selectedFile = null;

    const fileInfo = document.getElementById('kiroFileInfo');
    const uploadArea = document.getElementById('kiroUploadArea');
    const confirmBtn = document.getElementById('confirmKiroUpload');
    const fileInput = document.getElementById('kiroFileInput');
    const accountNameInput = document.getElementById('kiroAccountName');

    if (fileInfo) fileInfo.style.display = 'none';
    if (uploadArea) uploadArea.style.display = 'flex';
    if (confirmBtn) confirmBtn.disabled = true;
    if (fileInput) fileInput.value = '';
    if (accountNameInput) accountNameInput.value = '';
}
