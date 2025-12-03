// Configuration des URLs des services backend
const API_CONFIG = {
    AUTH_SERVICE: 'http://localhost:8000/api',
    TRANSACTION_SERVICE: 'http://localhost:8001',
    FRAUD_DETECTION_SERVICE: 'http://localhost:8002'
};

// Variables globales
let currentUser = null;
let authToken = null;
let transactions = [];
let updateInterval = null;

// ==================== UTILITAIRES ====================

// Afficher un message temporaire
function showMessage(text, type = 'info') {
    const messageEl = document.getElementById('message');
    if (!messageEl) {
        console.log(`MESSAGE [${type}]:`, text);
        return;
    }
    messageEl.textContent = text;
    messageEl.className = `message ${type}`;
    messageEl.style.display = 'block';
    
    setTimeout(() => {
        messageEl.style.display = 'none';
    }, 4000);
}

// Afficher une notification
function showNotification(text) {
    const notificationEl = document.getElementById('notification');
    const notificationText = document.getElementById('notification-text');
    
    if (!notificationEl || !notificationText) {
        console.log('NOTIFICATION:', text);
        showMessage(text, 'info');
        return;
    }
    
    notificationText.textContent = text;
    notificationEl.style.display = 'flex';
    
    // Auto-fermeture après 5 secondes
    setTimeout(() => {
        closeNotification();
    }, 5000);
}

function closeNotification() {
    const notificationEl = document.getElementById('notification');
    if (notificationEl) {
        notificationEl.style.display = 'none';
    }
}

// Faire une requête HTTP avec gestion des erreurs améliorée
async function fetchAPI(url, options = {}) {
    try {
        const defaultOptions = {
            headers: {
                'Content-Type': 'application/json',
            }
        };
        
        // Ajouter le token si disponible
        if (authToken) {
            defaultOptions.headers['Authorization'] = `Bearer ${authToken}`;
        }
        
        console.log('🌐 Requête API:', {
            url,
            method: options.method || 'GET',
            hasToken: !!authToken
        });
        
        const response = await fetch(url, { ...defaultOptions, ...options });
        
        // Gérer les erreurs HTTP
        if (!response.ok) {
            let errorData;
            try {
                errorData = await response.json();
                console.error('❌ Erreur API - Détails:', {
                    status: response.status,
                    statusText: response.statusText,
                    data: errorData,
                    url: url
                });
            } catch {
                errorData = { detail: `Erreur HTTP ${response.status}: ${response.statusText}` };
            }
            
            // Créer un message d'erreur détaillé
            let errorMessage = errorData.detail || errorData.message;
            
            // Si c'est un objet d'erreurs de validation (Django/FastAPI)
            if (typeof errorData === 'object' && !errorMessage) {
                const errors = [];
                for (const [field, messages] of Object.entries(errorData)) {
                    const errorText = Array.isArray(messages) ? messages.join(', ') : messages;
                    errors.push(`${field}: ${errorText}`);
                }
                errorMessage = errors.join('; ');
            }
            
            throw new Error(errorMessage || `Erreur HTTP: ${response.status}`);
        }
        
        const data = await response.json();
        console.log('✅ Réponse API:', data);
        return data;
        
    } catch (error) {
        console.error('❌ Erreur complète:', error);
        throw error;
    }
}

// Sauvegarder le token
function saveToken(token) {
    authToken = token;
    localStorage.setItem('authToken', token);
}

// Charger le token
function loadToken() {
    authToken = localStorage.getItem('authToken');
    return authToken;
}

// Supprimer le token
function clearToken() {
    authToken = null;
    localStorage.removeItem('authToken');
}

// ==================== AUTHENTIFICATION ====================

// Connexion
async function login() {
    const username = document.getElementById('login-username').value.trim();
    const password = document.getElementById('login-password').value;
    
    if (!username || !password) {
        showMessage('Veuillez remplir tous les champs', 'error');
        return;
    }
    
    try {
        console.log('🔐 Tentative de connexion pour:', username);
        
        const data = await fetchAPI(`${API_CONFIG.AUTH_SERVICE}/token/`, {
            method: 'POST',
            body: JSON.stringify({ username, password })
        });
        
        saveToken(data.access);
        currentUser = username;
        localStorage.setItem('currentUser', username);
        
        showMessage('Connexion réussie!', 'success');
        showDashboard();
        
        // ⚡ Charger les transactions
        await loadTransactions(false);
        startAutoUpdate();
        
    } catch (error) {
        console.error('❌ Erreur de connexion:', error);
        showMessage(`Erreur de connexion: ${error.message}`, 'error');
    }
}

// Inscription
async function register() {
    const username = document.getElementById('reg-username').value.trim();
    const email = document.getElementById('reg-email').value.trim();
    const password = document.getElementById('reg-password').value;
    const passwordConfirm = document.getElementById('reg-password-confirm').value;
    
    // Validation côté client
    if (!username || !email || !password || !passwordConfirm) {
        showMessage('Veuillez remplir tous les champs', 'error');
        return;
    }
    
    if (username.length < 3) {
        showMessage('Le nom d\'utilisateur doit contenir au moins 3 caractères', 'error');
        return;
    }
    
    if (password !== passwordConfirm) {
        showMessage('Les mots de passe ne correspondent pas', 'error');
        return;
    }
    
    if (password.length < 8) {
        showMessage('Le mot de passe doit contenir au moins 8 caractères', 'error');
        return;
    }
    
    // Validation email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        showMessage('Adresse email invalide', 'error');
        return;
    }
    
    try {
        const payload = { 
            username, 
            email, 
            password,
            password_confirm: passwordConfirm
        };
        console.log('📝 Tentative d\'inscription:', { username, email });
        
        const response = await fetchAPI(`${API_CONFIG.AUTH_SERVICE}/register/`, {
            method: 'POST',
            body: JSON.stringify(payload)
        });
        
        console.log('✅ Inscription réussie:', response);
        showMessage('Inscription réussie! Vous pouvez maintenant vous connecter.', 'success');
        showLogin();
        
        // Pré-remplir le formulaire de connexion
        document.getElementById('login-username').value = username;
        document.getElementById('login-password').value = '';
        
        // Réinitialiser le formulaire d'inscription
        document.getElementById('reg-username').value = '';
        document.getElementById('reg-email').value = '';
        document.getElementById('reg-password').value = '';
        document.getElementById('reg-password-confirm').value = '';
        
    } catch (error) {
        console.error('❌ Erreur d\'inscription:', error);
        showMessage(`Erreur d'inscription: ${error.message}`, 'error');
    }
}

// Déconnexion
function logout() {
    clearToken();
    currentUser = null;
    transactions = [];
    stopAutoUpdate();
    localStorage.removeItem('currentUser');
    
    const logoutBtn = document.getElementById('logout-btn');
    const dashboardSection = document.getElementById('dashboard-section');
    const transactionSection = document.getElementById('transaction-section');
    const transactionsList = document.getElementById('transactions-list');
    const userInfo = document.getElementById('user-info');
    const authSection = document.getElementById('auth-section');
    const loginForm = document.getElementById('login-form');
    
    if (dashboardSection) dashboardSection.style.display = 'none';
    if (transactionSection) transactionSection.style.display = 'none';
    if (transactionsList) transactionsList.style.display = 'none';
    if (userInfo) userInfo.style.display = 'none';
    if (logoutBtn) logoutBtn.style.display = 'none';
    
    if (authSection) authSection.style.display = 'block';
    if (loginForm) loginForm.style.display = 'block';
    
    showMessage('Déconnexion réussie', 'info');
}

// Afficher le dashboard
function showDashboard() {
    const authSection = document.getElementById('auth-section');
    const dashboardSection = document.getElementById('dashboard-section');
    const transactionSection = document.getElementById('transaction-section');
    const transactionsList = document.getElementById('transactions-list');
    const userInfo = document.getElementById('user-info');
    const currentUserSpan = document.getElementById('current-user');
    const logoutBtn = document.getElementById('logout-btn');
    
    if (authSection) authSection.style.display = 'none';
    if (dashboardSection) dashboardSection.style.display = 'block';
    if (transactionSection) transactionSection.style.display = 'block';
    if (transactionsList) transactionsList.style.display = 'block';
    if (userInfo) userInfo.style.display = 'block';
    if (currentUserSpan) currentUserSpan.textContent = currentUser;
    if (logoutBtn) logoutBtn.style.display = 'inline-flex';
    
    console.log('📊 Dashboard affiché');
}

// Basculer vers inscription
function showRegister() {
    const loginForm = document.getElementById('login-form');
    const registerForm = document.getElementById('register-form');
    
    if (loginForm) loginForm.style.display = 'none';
    if (registerForm) registerForm.style.display = 'block';
}

// Basculer vers connexion
function showLogin() {
    const registerForm = document.getElementById('register-form');
    const loginForm = document.getElementById('login-form');
    
    if (registerForm) registerForm.style.display = 'none';
    if (loginForm) loginForm.style.display = 'block';
}

// ==================== TRANSACTIONS ====================

// Créer une transaction avec affichage optimiste
async function createTransaction(event) {
    event.preventDefault();
    
    const amount = parseFloat(document.getElementById('amount').value);
    const merchant = document.getElementById('merchant').value.trim();
    const category = document.getElementById('category').value;
    const description = document.getElementById('description').value.trim();
    
    if (!amount || !merchant || !category) {
        showMessage('Veuillez remplir tous les champs obligatoires', 'error');
        return;
    }
    
    if (amount <= 0) {
        showMessage('Le montant doit être supérieur à 0', 'error');
        return;
    }
    
    if (!currentUser) {
        showMessage('Vous devez être connecté pour créer une transaction', 'error');
        return;
    }
    
    try {
        const transactionData = {
            user_id: currentUser,
            amount,
            merchant,
            category,
            description: description || '',
            timestamp: new Date().toISOString()
        };
        
        console.log('📤 Création de transaction:', transactionData);
        
        // ⚡ Créer une transaction temporaire pour affichage instantané
        const tempTransaction = {
            ...transactionData,
            id: 'temp-' + Date.now(),
            status: 'pending',
            is_fraud: false,
            fraud_score: null,
            created_at: transactionData.timestamp
        };
        
        console.log('⚡ Affichage optimiste - ajout immédiat');
        
        // ✅ AJOUT IMMÉDIAT au tableau local
        transactions.unshift(tempTransaction);
        displayTransactions(transactions);
        updateDashboardStats();
        
        // Afficher message de succès IMMÉDIATEMENT
        showMessage('✅ Transaction en cours...', 'info');
        
        // Réinitialiser le formulaire IMMÉDIATEMENT
        document.getElementById('transaction-form').reset();
        
        console.log('🌐 Envoi vers API...');
        
        // ⚡ Faire la vraie requête API
        const transaction = await fetchAPI(`${API_CONFIG.TRANSACTION_SERVICE}/transactions`, {
            method: 'POST',
            body: JSON.stringify(transactionData)
        });
        
        console.log('✅ Réponse API reçue:', transaction);
        
        // ⚡ Remplacer la transaction temporaire par la vraie
        const tempIndex = transactions.findIndex(t => t.id === tempTransaction.id);
        if (tempIndex !== -1) {
            transactions[tempIndex] = transaction;
            console.log('🔄 Transaction mise à jour avec résultat ML');
        } else {
            transactions.unshift(transaction);
        }
        
        // ⚡ Mise à jour de l'affichage
        displayTransactions(transactions);
        updateDashboardStats();
        
        // Message final
        showMessage('✅ Transaction créée avec succès!', 'success');
        
        // Afficher notification de fraude si détectée par le ML
        if (transaction.is_fraud) {
            showNotification(`⚠️ ALERTE FRAUDE: Transaction de ${amount}€ chez ${merchant} bloquée par ML!`);
            showMessage('❌ Transaction bloquée - Fraude détectée par le modèle ML!', 'error');
        } else if (transaction.fraud_score !== null && transaction.fraud_score > 0.7) {
            showNotification(`⚠️ Score de risque élevé (ML): ${(transaction.fraud_score * 100).toFixed(1)}%`);
        }
        
    } catch (error) {
        console.error('❌ Erreur création transaction:', error);
        
        // Retirer la transaction temporaire en cas d'erreur
        transactions = transactions.filter(t => !t.id.toString().startsWith('temp-'));
        displayTransactions(transactions);
        updateDashboardStats();
        
        showMessage(`❌ Erreur: ${error.message}`, 'error');
    }
}

// Charger les transactions
async function loadTransactions(silent = false) {
    if (!silent) {
        console.log('🔄 Chargement des transactions depuis l\'API...');
        
        const container = document.getElementById('transactions-container');
        if (container && transactions.length === 0) {
            container.innerHTML = `
                <div class="loading">
                    <i class="fas fa-spinner fa-spin fa-2x"></i>
                    <p>Chargement des transactions...</p>
                </div>
            `;
        }
    }
    
    try {
        const data = await fetchAPI(`${API_CONFIG.TRANSACTION_SERVICE}/transactions`);
        
        if (data.transactions) {
            transactions = data.transactions;
        } else if (Array.isArray(data)) {
            transactions = data;
        } else {
            transactions = [];
        }
        
        console.log('📊', transactions.length, 'transactions chargées depuis la base de données');
        
        displayTransactions(transactions);
        updateDashboardStats();
        
    } catch (error) {
        console.error('❌ Erreur chargement:', error);
        if (!silent) {
            showMessage(`Erreur de chargement: ${error.message}`, 'error');
        }
        displayTransactions([]);
    }
}

// Afficher les transactions (optimisé)
function displayTransactions(transactionsToDisplay) {
    const container = document.getElementById('transactions-container');
    
    if (!container) {
        console.error('❌ Container introuvable');
        return;
    }
    
    const startTime = performance.now();
    
    if (!transactionsToDisplay || transactionsToDisplay.length === 0) {
        container.innerHTML = `
            <div class="empty-state">
                <i class="fas fa-inbox fa-3x" style="color: var(--text-secondary); margin-bottom: 1rem;"></i>
                <p>Aucune transaction</p>
                <p style="color: var(--text-secondary); font-size: 0.9em;">Créez votre première transaction pour tester le modèle ML</p>
            </div>
        `;
        return;
    }
    
    // Construction HTML optimisée
    const htmlParts = [];
    
    for (let i = 0; i < transactionsToDisplay.length; i++) {
        const t = transactionsToDisplay[i];
        const statusClass = t.status || 'pending';
        const isFraud = t.is_fraud || statusClass === 'blocked' || statusClass === 'BLOCKED';
        const fraudClass = isFraud ? 'fraud' : statusClass.toLowerCase();
        
        // Indicateur de transaction temporaire
        const isPending = t.id && t.id.toString().startsWith('temp-');
        const pendingIndicator = isPending ? '<span class="pending-badge">⏳ Analyse ML...</span>' : '';
        
        let scoreHTML = '';
        if (t.fraud_score != null) {
            const scoreClass = t.fraud_score < 0.3 ? 'score-low' : (t.fraud_score < 0.7 ? 'score-medium' : 'score-high');
            scoreHTML = `<p class="fraud-score-display ${scoreClass}">
                <i class="fas fa-brain"></i> Score ML: ${(t.fraud_score * 100).toFixed(1)}%
            </p>`;
        }
        
        htmlParts.push(`
            <div class="transaction-item ${fraudClass}">
                <div class="transaction-info">
                    <h4><i class="fas fa-store"></i> ${t.merchant} ${pendingIndicator}</h4>
                    <p><strong><i class="fas fa-euro-sign"></i> ${t.amount.toFixed(2)} €</strong></p>
                    <p><i class="fas fa-tag"></i> ${t.category || 'N/A'}</p>
                    ${t.description ? `<p><i class="fas fa-comment"></i> ${t.description}</p>` : ''}
                    ${scoreHTML}
                    <p><small><i class="fas fa-clock"></i> ${formatDate(t.timestamp || t.created_at)}</small></p>
                </div>
                <div class="transaction-status status-${statusClass.toLowerCase()}">
                    ${getStatusText(statusClass, isFraud)}
                </div>
            </div>
        `);
    }
    
    // Mise à jour DOM en une seule opération
    container.innerHTML = htmlParts.join('');
    
    const endTime = performance.now();
    console.log(`⚡ Affichage de ${transactionsToDisplay.length} transactions en ${(endTime - startTime).toFixed(2)}ms`);
}

// Obtenir le texte du statut
function getStatusText(status, isFraud) {
    if (isFraud) return '🚫 FRAUDE (ML)';
    
    const statusUpper = status.toUpperCase();
    switch(statusUpper) {
        case 'APPROVED': return '✓ Approuvée';
        case 'BLOCKED': return '✗ Bloquée';
        case 'PENDING': return '⏳ Analyse...';
        default: return '? Inconnu';
    }
}

// Formater la date
function formatDate(dateString) {
    if (!dateString) return 'Date inconnue';
    const date = new Date(dateString);
    return date.toLocaleString('fr-FR', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
    });
}

// ==================== FILTRES ====================

// Appliquer les filtres
function applyFilters() {
    const statusFilter = document.getElementById('filter-status');
    const merchantSearch = document.getElementById('search-merchant');
    
    if (!statusFilter || !merchantSearch) return;
    
    const statusValue = statusFilter.value;
    const merchantValue = merchantSearch.value.toLowerCase();
    
    let filtered = [...transactions];
    
    if (statusValue) {
        filtered = filtered.filter(t => t.status && t.status.toLowerCase() === statusValue.toLowerCase());
    }
    
    if (merchantValue) {
        filtered = filtered.filter(t => 
            t.merchant.toLowerCase().includes(merchantValue)
        );
    }
    
    displayTransactions(filtered);
    showMessage(`${filtered.length} transaction(s) trouvée(s)`, 'info');
}

// ==================== DASHBOARD ====================

// Mettre à jour les statistiques
function updateDashboardStats() {
    const totalTransactionsEl = document.getElementById('total-transactions');
    const fraudTransactionsEl = document.getElementById('fraud-transactions');
    const totalAmountEl = document.getElementById('total-amount');
    
    const totalTransactions = transactions.length;
    const fraudTransactions = transactions.filter(t => 
        t.is_fraud || t.status === 'blocked' || t.status === 'BLOCKED'
    ).length;
    const totalAmount = transactions.reduce((sum, t) => sum + (t.amount || 0), 0);
    
    if (totalTransactionsEl) {
        animateValue('total-transactions', 0, totalTransactions, 1000);
    }
    if (fraudTransactionsEl) {
        animateValue('fraud-transactions', 0, fraudTransactions, 1000);
    }
    if (totalAmountEl) {
        totalAmountEl.textContent = `${totalAmount.toFixed(2)} €`;
    }
}

// Animer un compteur
function animateValue(id, start, end, duration) {
    const element = document.getElementById(id);
    if (!element) return;
    
    const range = end - start;
    const increment = range / (duration / 16);
    let current = start;
    
    const timer = setInterval(() => {
        current += increment;
        if (current >= end) {
            element.textContent = Math.round(end);
            clearInterval(timer);
        } else {
            element.textContent = Math.round(current);
        }
    }, 16);
}

// ==================== EXPORT ====================

// Exporter en CSV
function exportTransactions() {
    if (transactions.length === 0) {
        showMessage('Aucune transaction à exporter', 'error');
        return;
    }
    
    const headers = ['Date', 'Montant', 'Marchand', 'Catégorie', 'Statut', 'Score ML', 'Description'];
    const csvContent = [
        headers.join(','),
        ...transactions.map(t => [
            formatDate(t.timestamp || t.created_at),
            t.amount.toFixed(2),
            `"${t.merchant}"`,
            t.category || '',
            t.status || 'pending',
            t.fraud_score !== null && t.fraud_score !== undefined ? (t.fraud_score * 100).toFixed(2) + '%' : 'N/A',
            `"${(t.description || '').replace(/"/g, '""')}"`
        ].join(','))
    ].join('\n');
    
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `transactions_ml_${new Date().toISOString().split('T')[0]}.csv`;
    link.click();
    
    showMessage('Export réussi!', 'success');
}

// ==================== THÈME ====================

// Basculer le thème
function toggleTheme() {
    document.body.classList.toggle('dark');
    const isDark = document.body.classList.contains('dark');
    
    const themeBtn = document.getElementById('theme-toggle');
    if (themeBtn) {
        themeBtn.innerHTML = isDark 
            ? '<i class="fas fa-sun"></i>' 
            : '<i class="fas fa-moon"></i>';
    }
    
    localStorage.setItem('darkMode', isDark);
}

// ==================== MISE À JOUR AUTO ====================

// Démarrer les mises à jour
function startAutoUpdate() {
    const statusEl = document.getElementById('real-time-status');
    
    updateInterval = setInterval(() => {
        // Chargement silencieux pour ne pas spammer
        loadTransactions(true);
        if (statusEl) {
            statusEl.innerHTML = `<i class="fas fa-sync-alt"></i> Dernière sync: ${new Date().toLocaleTimeString('fr-FR')}`;
        }
    }, 30000); // 30 secondes
}

// Arrêter les mises à jour
function stopAutoUpdate() {
    if (updateInterval) {
        clearInterval(updateInterval);
        updateInterval = null;
    }
}

// ==================== INITIALISATION ====================

window.addEventListener('DOMContentLoaded', () => {
    console.log('🚀 Application Fraud Detection ML démarrée');
    console.log('🤖 Modèles ML: Random Forest + Isolation Forest');
    
    // Charger le thème
    const savedDarkMode = localStorage.getItem('darkMode') === 'true';
    if (savedDarkMode) {
        document.body.classList.add('dark');
        const themeBtn = document.getElementById('theme-toggle');
        if (themeBtn) {
            themeBtn.innerHTML = '<i class="fas fa-sun"></i>';
        }
    }
    
    // Vérifier la session
    const savedToken = loadToken();
    const savedUser = localStorage.getItem('currentUser');
    
    if (savedToken && savedUser) {
        authToken = savedToken;
        currentUser = savedUser;
        
        console.log('🔑 Session restaurée pour:', currentUser);
        
        showDashboard();
        
        // Chargement des transactions
        loadTransactions(false).then(() => {
            showMessage('Session restaurée', 'info');
            startAutoUpdate();
        }).catch((error) => {
            console.error('Erreur restauration session:', error);
            if (error.message.includes('401') || error.message.includes('Unauthorized')) {
                clearToken();
                localStorage.removeItem('currentUser');
                showMessage('Session expirée, veuillez vous reconnecter', 'error');
                logout();
            }
        });
    }
    
    // Événements
    const loginPassword = document.getElementById('login-password');
    if (loginPassword) {
        loginPassword.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') login();
        });
    }
    
    const filterStatus = document.getElementById('filter-status');
    const searchMerchant = document.getElementById('search-merchant');
    
    if (filterStatus) filterStatus.addEventListener('change', applyFilters);
    if (searchMerchant) searchMerchant.addEventListener('input', applyFilters);
    
    console.log('✅ Application ML prête - Vérifiez que les services sont démarrés!');
});

window.addEventListener('beforeunload', () => {
    stopAutoUpdate();
});