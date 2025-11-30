// Configuration des URLs des services
const AUTH_URL = 'http://localhost:8000';
const TRANSACTION_URL = 'http://localhost:8001';
const FRAUD_DETECTION_URL = 'http://localhost:8002';

// Variables globales
let currentUser = null;
let accessToken = null;
let userId = null;

// Initialisation
document.addEventListener('DOMContentLoaded', () => {
    checkAuth();
});

// Fonctions d'authentification
async function login() {
    const username = document.getElementById('login-username').value;
    const password = document.getElementById('login-password').value;

    try {
        const response = await fetch(`${AUTH_URL}/api/login/`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ username, password })
        });

        const data = await response.json();

        if (response.ok) {
            accessToken = data.access || data.token;
            currentUser = data.user;
            userId = data.user.id;
            showMessage('Connexion réussie!', 'success');
            updateUI();
        } else {
            showMessage('Erreur de connexion: ' + (data.detail || data.message || 'Identifiants invalides'), 'error');
        }
    } catch (error) {
        showMessage('Erreur de connexion: ' + error.message, 'error');
    }
}

async function register() {
    const username = document.getElementById('reg-username').value;
    const email = document.getElementById('reg-email').value;
    const password = document.getElementById('reg-password').value;
    const passwordConfirm = document.getElementById('reg-password-confirm').value;

    if (password !== passwordConfirm) {
        showMessage('Les mots de passe ne correspondent pas', 'error');
        return;
    }

    try {
        const response = await fetch(`${AUTH_URL}/api/register/`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ username, email, password, password_confirm: passwordConfirm })
        });

        const data = await response.json();

        if (response.ok || response.status === 201) {
            accessToken = data.access || data.token;
            currentUser = data.user;
            userId = data.user.id;
            showMessage('Inscription réussie!', 'success');
            updateUI();
            showLogin();
        } else {
            showMessage('Erreur d\'inscription: ' + (data.detail || JSON.stringify(data)), 'error');
        }
    } catch (error) {
        showMessage('Erreur d\'inscription: ' + error.message, 'error');
    }
}

function logout() {
    accessToken = null;
    currentUser = null;
    userId = null;
    updateUI();
    showMessage('Déconnexion réussie', 'info');
}

function checkAuth() {
    // Vérifier si on a un token stocké
    const storedToken = localStorage.getItem('accessToken');
    const storedUser = localStorage.getItem('currentUser');
    
    if (storedToken && storedUser) {
        accessToken = storedToken;
        currentUser = JSON.parse(storedUser);
        userId = currentUser.id;
        updateUI();
    }
}

function updateUI() {
    const authSection = document.getElementById('auth-section');
    const transactionSection = document.getElementById('transaction-section');
    const transactionsList = document.getElementById('transactions-list');
    const loginForm = document.getElementById('login-form');
    const registerForm = document.getElementById('register-form');
    const userInfo = document.getElementById('user-info');
    const currentUserSpan = document.getElementById('current-user');

    if (accessToken && currentUser) {
        // Sauvegarder dans localStorage
        localStorage.setItem('accessToken', accessToken);
        localStorage.setItem('currentUser', JSON.stringify(currentUser));

        loginForm.style.display = 'none';
        registerForm.style.display = 'none';
        userInfo.style.display = 'block';
        transactionSection.style.display = 'block';
        transactionsList.style.display = 'block';
        currentUserSpan.textContent = currentUser.username;
        loadTransactions();
    } else {
        loginForm.style.display = 'block';
        userInfo.style.display = 'none';
        transactionSection.style.display = 'none';
        transactionsList.style.display = 'none';
        localStorage.removeItem('accessToken');
        localStorage.removeItem('currentUser');
    }
}

function showLogin() {
    document.getElementById('login-form').style.display = 'block';
    document.getElementById('register-form').style.display = 'none';
}

function showRegister() {
    document.getElementById('login-form').style.display = 'none';
    document.getElementById('register-form').style.display = 'block';
}

// Fonctions de transaction
async function createTransaction(event) {
    event.preventDefault();

    if (!accessToken || !userId) {
        showMessage('Veuillez vous connecter d\'abord', 'error');
        return;
    }

    const amount = parseFloat(document.getElementById('amount').value);
    const merchant = document.getElementById('merchant').value;
    const category = document.getElementById('category').value;
    const description = document.getElementById('description').value;

    try {
        const response = await fetch(`${TRANSACTION_URL}/transactions`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                user_id: userId.toString(),
                amount: amount,
                merchant: merchant,
                category: category || null,
                description: description || null
            })
        });

        const data = await response.json();

        if (response.ok) {
            showMessage(
                `Transaction ${data.status === 'BLOCKED' ? 'BLOQUÉE' : 'APPROUVÉE'}! ` +
                (data.is_fraud ? '⚠️ Fraude détectée!' : '✅ Transaction normale'),
                data.is_fraud ? 'error' : 'success'
            );
            document.getElementById('transaction-form').reset();
            loadTransactions();
        } else {
            showMessage('Erreur lors de la création: ' + (data.detail || JSON.stringify(data)), 'error');
        }
    } catch (error) {
        showMessage('Erreur de connexion au service de transaction: ' + error.message, 'error');
    }
}

async function loadTransactions() {
    if (!accessToken || !userId) return;

    const container = document.getElementById('transactions-container');
    container.innerHTML = '<p>Chargement...</p>';

    try {
        const response = await fetch(`${TRANSACTION_URL}/users/${userId}/transactions`, {
            headers: {
                'Authorization': `Bearer ${accessToken}`
            }
        });

        if (response.ok) {
            const data = await response.json();
            displayTransactions(data.transactions || []);
        } else {
            // Essayer sans auth si le service ne le requiert pas
            const response2 = await fetch(`${TRANSACTION_URL}/users/${userId}/transactions`);
            if (response2.ok) {
                const data = await response2.json();
                displayTransactions(data.transactions || []);
            } else {
                container.innerHTML = '<div class="empty-state"><p>Aucune transaction trouvée</p></div>';
            }
        }
    } catch (error) {
        container.innerHTML = '<div class="empty-state"><p>Erreur de chargement: ' + error.message + '</p></div>';
    }
}

function displayTransactions(transactions) {
    const container = document.getElementById('transactions-container');

    if (transactions.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>Aucune transaction pour le moment</p></div>';
        return;
    }

    container.innerHTML = transactions.map(tx => {
        const statusClass = tx.status?.toLowerCase() || 'pending';
        const statusText = tx.status || 'PENDING';
        const fraudBadge = tx.is_fraud ? '<span class="transaction-status status-blocked">FRAUDE</span>' : '';
        const score = tx.fraud_score !== null && tx.fraud_score !== undefined 
            ? `Score: ${tx.fraud_score.toFixed(4)}` 
            : '';

        return `
            <div class="transaction-item ${statusClass}">
                <div class="transaction-info">
                    <h4>${tx.merchant || 'N/A'} - ${tx.amount?.toFixed(2) || '0.00'} €</h4>
                    <p><strong>ID:</strong> ${tx.transaction_id || tx.id}</p>
                    <p><strong>Catégorie:</strong> ${tx.category || 'N/A'}</p>
                    <p><strong>Date:</strong> ${tx.timestamp || tx.created_at || 'N/A'}</p>
                    ${score ? `<p><strong>${score}</strong></p>` : ''}
                </div>
                <div>
                    <span class="transaction-status status-${statusClass}">${statusText}</span>
                    ${fraudBadge}
                </div>
            </div>
        `;
    }).join('');
}

// Fonction d'affichage de messages
function showMessage(text, type = 'info') {
    const messageDiv = document.getElementById('message');
    messageDiv.textContent = text;
    messageDiv.className = `message ${type}`;
    messageDiv.style.display = 'block';

    setTimeout(() => {
        messageDiv.style.display = 'none';
    }, 5000);
}

