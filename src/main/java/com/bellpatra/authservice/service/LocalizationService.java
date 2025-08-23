package com.bellpatra.authservice.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

/**
 * Localization Service
 * Handles message localization for different languages
 * 
 * @author Bellpatra Team
 * @version 1.0.0
 * @since 2024-08-23
 */
@Service
public class LocalizationService {
    
    private final MessageSource messageSource;
    
    @Value("${app.default.locale:en}")
    private String defaultLocale;
    
    @Value("${app.supported.locales:en,hi,es,fr,de,ar,zh,ja}")
    private String supportedLocales;
    
    public LocalizationService(MessageSource messageSource) {
        this.messageSource = messageSource;
    }
    
    /**
     * Get localized message for the current locale
     * 
     * @param messageKey Message key to localize
     * @param args Arguments for message formatting
     * @return Localized message
     */
    public String getMessage(String messageKey, Object... args) {
        Locale currentLocale = LocaleContextHolder.getLocale();
        return messageSource.getMessage(messageKey, args, messageKey, currentLocale);
    }
    
    /**
     * Get localized message for a specific locale
     * 
     * @param messageKey Message key to localize
     * @param locale Locale to use for localization
     * @param args Arguments for message formatting
     * @return Localized message
     */
    public String getMessage(String messageKey, Locale locale, Object... args) {
        return messageSource.getMessage(messageKey, args, messageKey, locale);
    }
    
    /**
     * Get localized message for a specific language code
     * 
     * @param messageKey Message key to localize
     * @param languageCode Language code (e.g., "en", "hi", "es")
     * @param args Arguments for message formatting
     * @return Localized message
     */
    public String getMessage(String messageKey, String languageCode, Object... args) {
        Locale locale = new Locale(languageCode);
        return messageSource.getMessage(messageKey, args, messageKey, locale);
    }
    
    /**
     * Get localized messages for all supported languages
     * 
     * @param messageKey Message key to localize
     * @param args Arguments for message formatting
     * @return Map of language codes to localized messages
     */
    public Map<String, String> getLocalizedMessages(String messageKey, Object... args) {
        Map<String, String> localizedMessages = new HashMap<>();
        
        String[] locales = supportedLocales.split(",");
        for (String localeStr : locales) {
            String languageCode = localeStr.trim();
            try {
                Locale locale = new Locale(languageCode);
                String message = messageSource.getMessage(messageKey, args, messageKey, locale);
                localizedMessages.put(languageCode, message);
            } catch (Exception e) {
                // If localization fails, use the message key as fallback
                localizedMessages.put(languageCode, messageKey);
            }
        }
        
        return localizedMessages;
    }
    
    /**
     * Get localized messages for specific languages
     * 
     * @param messageKey Message key to localize
     * @param languageCodes Array of language codes to localize for
     * @param args Arguments for message formatting
     * @return Map of language codes to localized messages
     */
    public Map<String, String> getLocalizedMessages(String messageKey, String[] languageCodes, Object... args) {
        Map<String, String> localizedMessages = new HashMap<>();
        
        for (String languageCode : languageCodes) {
            try {
                Locale locale = new Locale(languageCode.trim());
                String message = messageSource.getMessage(messageKey, args, messageKey, locale);
                localizedMessages.put(languageCode.trim(), message);
            } catch (Exception e) {
                // If localization fails, use the message key as fallback
                localizedMessages.put(languageCode.trim(), messageKey);
            }
        }
        
        return localizedMessages;
    }
    
    /**
     * Get current locale from context
     * 
     * @return Current locale
     */
    public Locale getCurrentLocale() {
        return LocaleContextHolder.getLocale();
    }
    
    /**
     * Get current language code
     * 
     * @return Current language code
     */
    public String getCurrentLanguageCode() {
        return LocaleContextHolder.getLocale().getLanguage();
    }
    
    /**
     * Check if a language is supported
     * 
     * @param languageCode Language code to check
     * @return true if language is supported, false otherwise
     */
    public boolean isLanguageSupported(String languageCode) {
        String[] locales = supportedLocales.split(",");
        for (String locale : locales) {
            if (locale.trim().equalsIgnoreCase(languageCode)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Get all supported language codes
     * 
     * @return Array of supported language codes
     */
    public String[] getSupportedLanguageCodes() {
        return supportedLocales.split(",");
    }
    
    /**
     * Get default language code
     * 
     * @return Default language code
     */
    public String getDefaultLanguageCode() {
        return defaultLocale;
    }
    
    /**
     * Set locale for current thread
     * 
     * @param locale Locale to set
     */
    public void setLocale(Locale locale) {
        LocaleContextHolder.setLocale(locale);
    }
    
    /**
     * Set locale for current thread by language code
     * 
     * @param languageCode Language code to set
     */
    public void setLocale(String languageCode) {
        Locale locale = new Locale(languageCode);
        LocaleContextHolder.setLocale(locale);
    }
    
    /**
     * Reset locale to default for current thread
     */
    public void resetToDefaultLocale() {
        Locale defaultLocale = new Locale(this.defaultLocale);
        LocaleContextHolder.setLocale(defaultLocale);
    }
}
