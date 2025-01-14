mod constants;

mod systems {
    mod registry;
    mod slot;
    mod society;
    mod wallet;
}

#[cfg(test)]
mod tests {
    mod setup;
    mod test_setup;
}
